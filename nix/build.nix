{ stdenv
, lib
, fetchurl
, makeWrapper
, patchelf
, wayland
, libglvnd
, vulkan-loader
, alsa-lib
, fontconfig
, freetype
, libxkbcommon
, xorg
, zlib
, zstd
, ...
}:

stdenv.mkDerivation rec {
  pname = "zed-editor";
  version = "0.169.2"; # or whatever version

  # Replace with the actual tarball URL from the Zed releases page
  src = fetchurl {
    url = "https://github.com/zed-industries/zed/releases/download/v0.169.2/zed-linux-x86_64.tar.gz";
    sha256 = "sha256-RECz3T3ZeJmr1on7nmcYTRr5/dvxxqys/uU6rV560Zg=";
  };

  nativeBuildInputs = [
    makeWrapper
    patchelf
  ];

  buildInputs = [
    alsa-lib
    fontconfig
    freetype
    libxkbcommon
    libglvnd
    wayland
    xorg.libxcb
    zlib
    zstd
    # ... any other libs required by the binary ...
  ];

  # We don't have a real 'build'—we just unpack and place files
  phases = [ "unpackPhase" "installPhase" ];

  # installPhase = ''
  #   # Everything is now in $PWD after the tarball is unpacked
  #   mkdir -p $out/bin $out/libexec

  #   # Suppose the tarball has a 'zed' binary
  #   cp zed $out/libexec/zed-editor
  #   chmod +x $out/libexec/zed-editor

  #   # For consistent naming, let’s link or copy a CLI to $out/bin
  #   ln -s $out/libexec/zed-editor $out/bin/zed

  #   # If needed, patchelf the binary so it can find libraries at runtime
  #   patchelf --set-rpath "${lib.makeLibraryPath [
  #     alsa-lib
  #     fontconfig
  #     freetype
  #     libxkbcommon
  #     libglvnd
  #     wayland
  #     xorg.libxcb
  #     zlib
  #     zstd
  #   ]}" $out/libexec/zed-editor

  #   # If the software needs environment vars or PATH tweaks, wrap it:
  #   wrapProgram $out/bin/zed \
  #     --set FONTCONFIG_FILE /etc/fonts/fonts.conf \
  #     --suffix PATH : "${lib.makeBinPath [ wayland vulkan-loader libxkbcommon freetype fontconfig ]}"
  # '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/libexec $out/share/icons/hicolor $out/share/applications

    cp ./bin/zed $out/bin/zed
    cp ./libexec/zed-editor $out/libexec/zed-editor
    cp -r ./share/icons/hicolor/* $out/share/icons/hicolor/
    cp ./share/applications/zed.desktop $out/share/applications/

    mkdir -p $out/lib
    cp -r ./lib/* $out/lib/

    wrapProgram $out/bin/zed \
      --prefix LD_LIBRARY_PATH : "$out/lib" \
      --set FONTCONFIG_FILE /etc/fonts/fonts.conf

    runHook postInstall
  '';



  meta = with lib; {
    description = "High-performance, multiplayer code editor (prebuilt binary)";
    homepage    = "https://zed.dev";
    license     = licenses.gpl3Only;
    platforms   = platforms.linux;
    maintainers = [ maintainers.michaelbuckley ];
  };
}
