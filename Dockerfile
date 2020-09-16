FROM ubuntu:18.04 AS builder

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	ca-certificates \
	wget \
	p7zip-full \
	unshield

RUN wget https://archive.org/download/worms_armageddon_201905/worms_armageddon.iso

# CD contents
RUN mkdir -p wa/cd \
	&& cd wa/cd \
	&& 7z x ../../worms_armageddon.iso

# Game installation directory
RUN mkdir wa/cab \
	&& cd wa/cab \
	&& unshield x ../cd/Install/data1.cab

# Merge and fix case
RUN mv wa/cab/Program_Executable_Files wa/game \
	&& cp -lnTR wa/cd/Data wa/game/DATA \
	&& bash -c 'mv wa/game/User/{g,G}raves' \
	&& bash -c 'mv wa/game/{g,G}raphics' \
	&& bash -c 'mv wa/game/Graphics/{optionsmenu,OptionsMenu}'

# Update
RUN wget https://worms2d.info/files/WA_update-3.8_[GOG]_Installer.exe

RUN cd wa/game \
	&& 7z x -aoa ../../WA_update-3.8_[GOG]_Installer.exe \
	&& rm -rf \$PLUGINSDIR

# Remove files unnecessary for non-interactive (headless) use
# RUN cd wa/game \
# 	&& find -regextype egrep -not -regex '^\.(|/(WA\.exe|ltfil10N\.DLL|ltkrn10N\.dll|lflmb10N\.dll|DATA(|/ImgHoles.*|/User(|/Languages(|/[0-9][^/]*(|/English.txt)))|/Mission.*|/Level.*|/Image.*|/Gfx(|/Gfx\.dir|/Water\.dir)|/Custom.*)))$' \
# 		-printf 'Deleting %p\n' -delete


FROM ubuntu:18.04

RUN dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
	wine-stable \
	wine32 \
	xvfb \
	&& rm -rf /var/lib/apt/lists/*

# Create WINEPREFIX
RUN xvfb-run wineboot --init \
	&& wineserver -k

# Copy game installation directory
COPY --from=builder wa/game /root/.wine/drive_c/WA

# Suppress Wine compatibility warning (only needed for 3.8 and earlier)
RUN wine reg add 'HKEY_CURRENT_USER\Software\Team17SoftwareLTD\WormsArmageddon\Options' /v WineCompatibilitySuggested /t REG_DWORD /d 0x7FFFFFFF \
	&& wineserver -k

# Add scripts
COPY scripts/* /usr/local/bin/
