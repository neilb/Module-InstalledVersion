#!/usr/bin/perl -w

package Module::InstalledVersion;

use strict;
use Carp;

use vars '$VERSION';
$VERSION = "0.02";

=pod

=head1 NAME

Module::InstalledVersion - Find out what version of a module is installed

=head1 SYNOPSIS

    use Module::InstalledVersion;
    my $m = new Module::InstalledVersion 'Foo::Bar';
    print "Version is $m->{version}\n";
    print "Directory is $m->{dir}\n";

=head1 DESCRIPTION

This module finds out what version of another module is installed,
without running that module.  It uses the same regexp technique used by
L<Extutils::MakeMaker> for figuring this out.

Note that it won't work if the module you're looking at doesn't set
$VERSION properly.  This is true of far too many CPAN modules.

=begin testing

BEGIN: { use_ok("Module::InstalledVersion", "Use Module::InstalledVersion") }

foreach my $module (qw(CPAN Fcntl Text::Wrap)) {
    if (eval "require $module" ) {
        my $m = Module::InstalledVersion->new($module);
        ok($m->isa("Module::InstalledVersion"), "create new object for $module");
        is($m->{version}, ${"${module}::VERSION"}, "Picked up version of $module");
    } else {
        print STDERR "Can't require $module\n";
    }
}

=end testing

=cut

sub new {
    shift;
    my ($module_name) = @_;
    my $self = {};
    $module_name =~ s/::/\//g;

    DIR: foreach my $dir (@INC) {
        my $filename = "$dir/$module_name.pm";
        if (-e $filename ) {
            if (open IN, "$filename") {
                while (<IN>) {
                    # the following regexp comes from the Extutils::MakeMaker 
                    # documentation.
                    if (/([\$*])(([\w\:\']*)\bVERSION)\b.*\=/) {
                        local $VERSION;
                        eval $_;
                        $self->{version} = $VERSION;
                        $self->{dir} = $dir;
                        last DIR;
                    }
                }
            } else {
                carp "Can't open $filename: $!";
            }
        }
    }
    bless $self;
    return $self;
}

=head1 COPYRIGHT

Copyright (c) 2001 Kirrily Robert.
This program is free software; you may redistribute it
and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<Extutils::MakeMaker>

=head1 AUTHOR

Kirrily "Skud" Robert <skud@cpan.org>

=cut
