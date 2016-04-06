use strict;
use warnings;

use Module::Build;

our $VERSION = '1.0.0';

my $class = Module::Build->subclass(
    class => 'Module::Build::Custom',
    code  => <<'SUBCLASS' );

sub ACTION_uninstall {
    my $self = shift;

    use File::Path qw(remove_tree);

    printf "Uninstalling smime-mta\n";
    remove_tree($self->install_base . '/etc/smime-mta',
                $self->install_base . '/share/doc/smime-mta',
                $self->install_base . '/sbin/smime-mta',
                $self->install_base . '/bin/ldapgetcert',
                $self->install_base . '/share/man/man1/ldapgetcert.1',
                $self->install_base . '/share/man/man5/smime-mta.conf.5',
                $self->install_base . '/share/man/man8/smime-mta.8',
                { verbose => 1 } );
}

sub ACTION_install {
    my $self = shift;

    use Pod::Man;

    # Create the directory structure
    mkdir $self->install_base;
    mkdir $self->install_base . '/bin';
    mkdir $self->install_base . '/sbin';
    mkdir $self->install_base . '/etc';
    mkdir $self->install_base . '/share/doc';
    mkdir $self->install_base . '/share/man/man1';
    mkdir $self->install_base . '/share/man/man5';
    mkdir $self->install_base . '/share/man/man8';

    # Ensure the proper modes of the directory structure.
    chmod 0755, $self->install_base,
                $self->install_base . '/bin',
                $self->install_base . '/sbin',
                $self->install_base . '/etc',
                $self->install_base . '/share/doc',
                $self->install_base . '/share/man/man1',
                $self->install_base . '/share/man/man5',
                $self->install_base . '/share/man/man8',

    # Call the parent install function
    $self->SUPER::ACTION_install;

    # Create the man pages
    printf "Installing %s\n", $self->install_base . '/share/man/man1/ldapgetcert.1';
    my $pod1 = Pod::Man->new( release => $VERSION, section => 1 );
    $pod1->parse_from_file( 'ldapgetcert', $self->install_base . '/share/man/man1/ldapgetcert.1' );

    printf "Installing %s\n", $self->install_base . '/share/man/man5/smime-mta.conf.5';
    my $pod5 = Pod::Man->new( release => $VERSION, section => 5 );
    $pod5->parse_from_file( 'smime-mta.conf.pod', $self->install_base . '/share/man/man5/smime-mta.conf.5' );

    printf "Installing %s\n", $self->install_base . '/share/man/man8/smime-mta.8';
    my $pod8 = Pod::Man->new( release => $VERSION, section => 8 );
    $pod8->parse_from_file( 'smime-mta', $self->install_base . '/share/man/man8/smime-mta.8' );
}
SUBCLASS

my $build = $class->new(

    # Distribution information
    dist_name         => 'smime-mta',
    dist_version      => $VERSION,
    dist_version_from => 'Build.PL',
    dist_author       => 'Bennett Samowich <bennett@foolean.org>',
    dist_abstract     => 'S/MIME MTA Wrapper',
    license           => 'perl',

    # Installation information
    bin_files    => { 'ldapgetcert'        => 'bin/ldapgetcert', },
    sbin_files   => { 'smime-mta'          => 'sbin/smime-mta', },
    etc_files    => { 'etc/smime-mta.conf' => 'etc/smime-mta/smime-mta.conf', },
    doc_files    => { 'README'             => 'doc/smime-mta/README', },
    install_base => '/usr',
    install_path => {
        'bin'  => '/usr/bin',
        'sbin' => '/usr/sbin',
        'etc'  => '/etc',
        'doc'  => '/usr/share/doc',
    },

    # Additional modules that are required
    configure_requires => {
        'Module::Build' => 0.38,
        'File::Path'    => 0,
        'Pod::Man'      => 0,
    },
    requires => {
        'Config::General'      => 0,
        'Crypt::OpenSSL::X509' => 0,
        'Crypt::SMIME'         => 0,
        'English'              => 0,
        'File::Basename'       => 0,
        'Getopt::Long'         => 0,
        'IO::Select'           => 0,
        'Mail::ExpandAliases'  => 0,
        'Mail::Internet'       => 0,
        'Net::Domain'          => 0,
        'Net::LDAPS'           => 0,
        'Scalar::Util'         => 0,
        'strict'               => 0,
        'Sys::Syslog'          => 0,
        'warnings'             => 0,
    },
);

$build->add_build_element('doc');
$build->add_build_element('etc');
$build->add_build_element('bin');
$build->add_build_element('sbin');
$build->create_build_script;

