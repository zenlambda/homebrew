require 'formula'
require 'set'
class IgnoreBoneyardSubversionDownloadStrategy < SubversionDownloadStrategy
  def fetch_repo target, url, revision=nil, ignore_externals=false
    # Use "svn up" when the repository already exists locally.
    # This saves on bandwidth and will have a similar effect to verifying the
    # cache as it will make any changes to get the right revision.
		svncommand = target.exist? ? 'up' : 'checkout'
    args = [@@svn, svncommand]
    # SVN shipped with XCode 3.1.4 can't force a checkout.
    args << '--force' unless MacOS.version == :leopard and @@svn == '/usr/bin/svn'
    args << url if !target.exist?
    args << target
    args << '-r' << revision if revision
		args << '--depth' << 'immediates' if !target.exist?
    args << '--ignore-externals' if ignore_externals
		ohai "executing #{args}"
    safe_system(*args)

		d = Dir.new(target)
		d.each { |c|
			unless Set['BoneYard','.svn','.','..'].include?(c) || !File.directory?(File.join(target,c)) then
				args = [@@svn, 'update'] 
				args << File.join(target,c)
				args << '--set-depth'
				args << 'infinity'

				ohai "executing #{args}"
				safe_system(*args)
			end
		}
	end

end
class Spimsimulator < Formula
  homepage 'http://spimsimulator.sourceforge.net/'
	head 'http://spimsimulator.svn.sourceforge.net/svnroot/spimsimulator/', :using => IgnoreBoneyardSubversionDownloadStrategy 
    
	def install
		ENV.append 'DESTDIR', prefix
		system "mkdir -p #{prefix}/bin" 
		system "mkdir -p #{prefix}/share/man/man1"

    system "make BIN_DIR=#{prefix}/bin EXCEPTION_DIR=#{prefix}/share/spim MAN_DIR=#{prefix}/share/man/man1 -C spim install" 
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


