{ lib
, stdenv
, vdr
, alsa-lib
, fetchFromGitHub
, xcbutilwm
, xorgserver
, ffmpeg
, libva
, libvdpau
, xorg
}:
stdenv.mkDerivation rec {
  pname = "vdr-softhddevice";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "ua0lnj";
    repo = "vdr-plugin-softhddevice";
    sha256 = "sha256-2kh8qMxaAjekvgjMVRmm1nPzlN2wjY/6qYjFyo6CLlg=";
    rev = "v${version}";
  };

  buildInputs = [
    vdr
    xcbutilwm
    ffmpeg
    alsa-lib
    libva
    libvdpau
    xorg.libxcb
    xorg.libX11
  ];

  makeFlags = [ "DESTDIR=$(out)" ];

  postPatch = ''
    substituteInPlace softhddev.c \
      --replace "LOCALBASE \"/bin/X\"" "\"${xorgserver}/bin/X\""
  '';

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "VDR SoftHDDevice Plug-in";
    maintainers = [ maintainers.ck3d ];
    license = licenses.gpl2;
    inherit (vdr.meta) platforms;
  };

}
