require 'formula'

class TidyHtml5 < Formula
  homepage 'http://w3c.github.io/tidy-html5/'
  head 'git://github.com/w3c/tidy-html5.git'
  sha1 ''

  def install
		ENV.deparallelize
		system "make", "PROJECT=tidy-html5", "-C", "build/gmake/"
    system "make", "PROJECT=tidy-html5", "runinst_prefix=#{prefix}", "devinst_prefix=#{prefix}", "install", "-C", "build/gmake/"
  end

  test do
		system "echo '<!doctype html><html><head><title></title></head><body></body></html>' | tidy-html5"
  end
end
