use strictures 1;
use Test::Exception;

BEGIN { require "t/moo-accessors.t"; }

require Moose;

my $meta = Class::MOP::get_metaclass_by_name('Foo');

my $attr;

ok($attr = $meta->get_attribute('one'), 'Meta-attribute exists');
is($attr->get_read_method, 'one', 'Method name');
is($attr->get_read_method_ref->body, Foo->can('one'), 'Right method');

is(Foo->new(one => 1, THREE => 3)->one, 1, 'Accessor still works');

is(
  Foo->meta->get_attribute('one')->get_read_method, 'one',
  'Method name via ->meta'
);

$meta = Moose::Meta::Class->initialize('Spoon');

$meta->superclasses('Moose::Object');

Moose::Util::apply_all_roles($meta, 'Bar');

my $spoon = Spoon->new(four => 4);

is($spoon->four, 4, 'Role application ok');

{
   package MooRequiresFour;

   use Moo::Role;

   requires 'four';

   package MooRequiresGunDog;

   use Moo::Role;

   requires 'gun_dog';
}

lives_ok {
   Moose::Util::apply_all_roles($meta, 'MooRequiresFour');
} 'apply role with satisified requirement';

dies_ok {
   Moose::Util::apply_all_roles($meta, 'MooRequiresGunDog');
} 'apply role with unsatisified requirement';

done_testing;
