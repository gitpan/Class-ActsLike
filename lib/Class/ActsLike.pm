package Class::ActsLike;

use strict;
use Scalar::Util;

use vars qw( $VERSION );
$VERSION = '0.01';

my %acts_like;

sub import
{
	my ($self, @acts_like) = @_;
	return unless @acts_like;

	my $caller     = caller;
	my $acts_like = ( $acts_like{ $caller } ||= {} );

	@$acts_like{ @acts_like } = (1) x @acts_like;
}

sub parent_acts_like
{
	my ($class, $acts_like) = @_;
	no strict 'refs';

	my $isa = *{ $class . '::ISA' }{ARRAY} or return;

	my $acts_likes = ( $acts_like{ $class } ||= {} );
	foreach my $parent (@$isa)
	{
		return $acts_likes->{ $acts_like } = 1
			if UNIVERSAL::acts_like( $parent, $acts_like );
	}

	return;
}

package UNIVERSAL;

sub acts_like
{
	my ($self, $acts_like) = @_;
	my $class = Scalar::Util::blessed $self || $self;

	return 1 if $acts_like eq $class;
	return 1 if exists $acts_like{ $class }{ $acts_like };
	return $acts_like{ $class }{ $acts_like } = 1
		if isa( $self, $acts_like );

	return Class::ActsLike::parent_acts_like( $class, $acts_like );
}

1;
__END__

=head1 NAME

Class::ActsLike - Perl extension for identifying class behavior similarities

=head1 SYNOPSIS

  package HappyFunBuilding;

  use Class::ActsLike qw( Bakery Arcade );

  ...

  $building->bake( 'cookies' ) if $building->acts_like( 'Bakery' );
  $building->play( 'pinball' ) if $building->acts_like( 'Arcade' );

=head1 DESCRIPTION

Polymorphism is a fundamental building block of object orientation.  Any two
objects that can receive the same messages with identical semantics can be
substituted for each other, regardless of their internal implementations.

Much of the introductory literature explains this concept in terms of
inheritance.  While inheritance is one way for two different classes to provide
different behavior for the same methods, it is not the only way.  Perl modules
such as the DBDs or Test::MockObject prove that classes do not have to inherit
from a common ancestor to be polymorphically equivalent.

Class::ActsLike provides an alternative to C<isa()>.

In the example class defined above, C<HappyFunBuilding> is marked as acting
like both the C<Bakery> and C<Arcade> classes.  It is not necessary to create
an ancestor class of C<Building>, or to have C<HappyFunBuilding> inherit from
both C<Bakery> and C<Arcade>.  As well, one could say:

  package FauxArcade;

  use Arcade;
  use Class::ActsLike 'Arcade';

  sub new
  {
	my $class = shift;
	bless { _arcade => Arcade->new() }, $class;
  }

Provided that the FauxArcade now delegates all methods an Arcade object can
receive to the contained Arcade object, this expresses the has-a relationship
more accurately.  Code which requires an Arcade object should, when handed an
object, check to see if the object acts like an Arcade object.  The FauxArcade
is suitable for any sort of Hollywood production where the real Arcade is
unnecessary.  This is why actors always seem so good at pinball.

This technique fulfills two goals:

=over 4

=item *

To allow you to check that the class or object you receive can handle the types
of messages you're going to send it.

=item *

To avoid dictating I<how> the class or object you receive handles the messages:
inheritance, delegation, composition, or re-implementation.

=back

By default, a new class automatically acts like itself, whether or not you use
C<Class::ActsLike> in its package.  It also automatically acts like all of its
parent classes, again without having had C<Class::ActsLike> used in its
namespace.

=head2 EXPORT

Class::ActsLike installs a new method C<acts_like()> in the C<UNIVERSAL>
package, so it is available to all classes and objects.  You may call it
directly, as:

  UNIVERSAL::acts_like( $class_or_object, $potentially_emulated_class );

or on a class name or object:

  $class_or_object->acts_like( $potentially_emulated_class );

It returns true or false, depending on whether the class or class of the object
acts like the target class.

=head1 AUTHOR

chromatic <chromatic@wgz.org>

=head1 THANKS TO

Allison Randal, for debating the theory of this idea.  Dan Sugalski and Dave
Rolsky for understanding the idea.

=head1 SEE ALSO

perl(1).

=cut
