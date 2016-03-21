class Openssh < Formula
  desc "OpenBSD freely-licensed SSH connectivity tools"
  homepage "http://www.openssh.com/"
  url "http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-7.2p2.tar.gz"
  mirror "https://www.mirrorservice.org/pub/OpenBSD/OpenSSH/portable/openssh-7.2p2.tar.gz"
  version "7.2p2"
  sha256 "a72781d1a043876a224ff1b0032daa4094d87565a68528759c1c2cab5482548c"

  bottle do
    sha256 "67af78204564c0b7490ef4677c17aa1443f37dc7526ae406847a35c389737b94" => :el_capitan
    sha256 "48dc522628399210e9c6f5bfdcafe9f717cda7056fb7344ff49184d251f5f75f" => :yosemite
    sha256 "555545c05753777bed0e8af137d0192f3962252f3d2decda5e9b1f9093ebcf6f" => :mavericks
  end

  # Please don't resubmit the keychain patch option. It will never be accepted.
  # https://github.com/Homebrew/homebrew-dupes/pull/482#issuecomment-118994372
  option "with-libressl", "Build with LibreSSL instead of OpenSSL"
  option "with-gsskex", "Add GSSAPI key exchange support"

  depends_on "openssl" => :recommended
  depends_on "libressl" => :optional
  depends_on "ldns" => :optional
  depends_on "pkg-config" => :build if build.with? "ldns"

  if build.with? "gsskex"
    patch do
      url "https://trac.macports.org/export/146143/trunk/dports/net/openssh/files/openssh-7.2p1-gsskex-all-20141021-mp-20160301.patch"
      sha256 '9b7b23f1a74275e0663547e0479b1e3f577ffe52d9a963e43f4e2f676074d8b0'
    end
  end

  if OS.mac?
    # Both these patches are applied by Apple.
    patch do
      url "https://raw.githubusercontent.com/Homebrew/patches/1860b0a74/openssh/patch-sandbox-darwin.c-apple-sandbox-named-external.diff"
      sha256 "d886b98f99fd27e3157b02b5b57f3fb49f43fd33806195970d4567f12be66e71"
    end

    patch do
     url "https://raw.githubusercontent.com/Homebrew/patches/d8b2d8c2/openssh/patch-sshd.c-apple-sandbox-named-external.diff"
     sha256 "3505c58bf1e584c8af92d916fe5f3f1899a6b15cc64a00ddece1dc0874b2f78f"
    end

    # Patch for SSH tunnelling issues caused by launchd changes on Yosemite
    patch do
      url "https://raw.githubusercontent.com/Homebrew/patches/d8b2d8c2/OpenSSH/launchd.patch"
      sha256 "df61404042385f2491dd7389c83c3ae827bf3997b1640252b018f9230eab3db3"
    end
  end

  def install
    ENV.append "CPPFLAGS", "-D__APPLE_SANDBOX_NAMED_EXTERNAL__" if OS.mac?

    args = %W[
      --with-libedit
      --with-pam
      --with-kerberos5
      --prefix=#{prefix}
      --sysconfdir=#{etc}/ssh
    ]

    if build.with? "libressl"
      args << "--with-ssl-dir=#{Formula["libressl"].opt_prefix}"
    else
      args << "--with-ssl-dir=#{Formula["openssl"].opt_prefix}"
    end

    args << "--with-ldns" if build.with? "ldns"

    system "./configure", *args
    system "make"
    system "make", "install"
  end
end
