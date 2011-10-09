module Studio54
  module Config
    module Environment

      ROOTDIR   = File.expand_path(File.dirname(__FILE__) + '/..')
      APPDIR    = File.join(ROOTDIR, "app")
      LIBDIR    = File.join(ROOTDIR, "lib")
      BINDIR    = File.join(ROOTDIR, "bin")
      CONFIGDIR = File.join(ROOTDIR, "config")
      MODELSDIR = File.join(APPDIR, "models")
      CONTROLLERSDIR = File.join(APPDIR, "controllers")

      $:.unshift(ROOTDIR)   unless $:.include? ROOTDIR
      $:.unshift(APPDIR)    unless $:.include? APPDIR
      $:.unshift(LIBDIR)    unless $:.include? LIBDIR
      $:.unshift(CONFIGDIR) unless $:.include? CONFIGDIR

    end
  end
end
