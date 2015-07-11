use Zef::Process;

# Manage multiple Proc/Proc::Async objects
class Zef::ProcessManager {
    has @.processes;
    has $.promise;
    has $.async;
    has $.cwd;

    submethod BUILD(Bool :$!async, :$!cwd = $*CWD) { }

    method create($file, *@args, :$cwd = $!cwd, :$id) {
        my $proc = Zef::Process.new(:$file, :@args, :$!async, :$cwd, :$id);
        @!processes.push: $proc;
        return $proc;
    }

    method start-all(:$p6flags) {
        $_.start for @!processes;
        $!promise = @!processes
            ?? Promise.allof( @!processes.map({ $_.promise }) )
            !! do { my $p = Promise.new; $p.keep($p) }; 
            # ^ todo: more appropriate action where `@!processes.elems == 0`
    }

    method tap-all(&code) {
        @!processes>>.tap(&code);
    }

    method ok-all {
        ?all(@!processes>>.ok);
    }

    method kill-all { }
}