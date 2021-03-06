use strictures 1;
use Test::More;

{
  package Foo;

  use Moo;

  has one => (is => 'rw', weak_ref => 1);

  package Foo2;

  use Moo;

  has one => (is => 'rw', lazy => 1, weak_ref => 1, default => sub { {} });
}

my $ref = {};
my $foo = Foo->new(one => $ref);
is($foo->one, $ref, 'value present');
ok(Scalar::Util::isweak($foo->{one}), 'value weakened');
is($foo->one($ref), $ref, 'value returned from setter');
undef $ref;
ok(!defined $foo->{one}, 'weak value gone');

my $foo2 = Foo2->new;
ok(my $ref2 = $foo2->one, 'value returned');
ok(Scalar::Util::isweak($foo2->{one}), 'value weakened');
is($foo2->one($ref2), $ref2, 'value returned from setter');
undef $ref2;
ok(!defined $foo->{one}, 'weak value gone');


# test readonly SVs
sub mk_ref { \ 'yay' };
my $foo_ro = eval { Foo->new(one => mk_ref()) };
if ($] < 5.008003) {
  like(
    $@,
    qr/\QReference to readonly value in "one" can not be weakened on Perl < 5.8.3/,
    'Expected exception thrown on old perls'
  );
}
elsif ($^O eq 'cygwin' and $] < 5.012000) {
  SKIP: { skip 'Static coderef reaping seems nonfunctional on cygwin < 5.12', 1 }
}
else {
  is(${$foo_ro->one},'yay', 'value present');
  ok(Scalar::Util::isweak($foo_ro->{one}), 'value weakened');

  { no warnings 'redefine'; *mk_ref = sub {} }
  ok (!defined $foo_ro->{one}, 'optree reaped, ro static value gone');
}

done_testing;
