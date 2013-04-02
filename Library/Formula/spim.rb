require 'formula'
require 'set'

# This is necessary to avoid downloading the 'BoneYard' directory, that
# contains old binaries for different platforms.
class IgnoreBoneyardSubversionDownloadStrategy < SubversionDownloadStrategy
  def fetch_repo target, url, revision=nil, ignore_externals=false
    # This code was shamelessly ripped from SubversionDownloadStrategy#fetch_repo
    svncommand = target.exist? ? 'up' : 'checkout'
    args = [@@svn, svncommand]
    # SVN shipped with XCode 3.1.4 can't force a checkout.
    args << '--force' unless MacOS.version == :leopard and @@svn == '/usr/bin/svn'
    args << url if !target.exist?
    args << target
    args << '-r' << revision if revision
    args << '--depth' << 'immediates' if !target.exist?
    args << '--ignore-externals' if ignore_externals
    quiet_safe_system(*args)

    d = Dir.new(target)
    d.each { |c|
      path = File.join(target,c)
      # TODO if we just build spim, maybe we should just checkout the dirs it needs
      # rather than excluding 'BoneYard'
      unless Set['BoneYard','.svn','.','..'].include?(c) ||
        !File.directory?(path) then
        args = [@@svn, 'update']
        args << path
        args << '--set-depth'
        args << 'infinity'

        quiet_safe_system(*args)
      end
    }
  end

end
class Spim < Formula
  homepage 'http://spimsimulator.sourceforge.net/'
	version '9.1.8'
  url 'http://spimsimulator.svn.sourceforge.net/svnroot/spimsimulator/', :using => IgnoreBoneyardSubversionDownloadStrategy, :revision => '603' # this is the revision from when Changlog last had a version update
  head 'http://spimsimulator.svn.sourceforge.net/svnroot/spimsimulator/', :using => IgnoreBoneyardSubversionDownloadStrategy

  def install
    ENV.append 'DESTDIR', prefix
    system "mkdir -p #{bin}"
    system "mkdir -p #{man1}"

    makecmd = [ 'make' ]
    makecmd << "BIN_DIR=#{bin}"
    makecmd << "EXCEPTION_DIR=#{share}/spim"
    makecmd << "MAN_DIR=#{man1}"
    makecmd << "-C spim"
    makecmd << "install"

    system(makecmd.join(' '))

    man1.install "Documentation/spim.man" => "spim.1"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test spimsimulator`.
    system "true"
  end
end
