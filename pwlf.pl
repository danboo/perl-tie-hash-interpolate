package pwlf;

use warnings;
use strict;

use Want 'want';

use Contextual::Return;

sub new
  {
  my $self  = bless {}, shift();
  return CODEREF { sub { $self->_value(@_) } } DEFAULT { $self };
  }

sub insert
  {
  my ($self, $key, $val) = @_;
  $self->{'_data'}{$key} = $val;
  }

sub _value
  {
  my ($self, $key) = @_;

  my $x_dn = 0;
  my $x_up = 2;

  my $lower = $self->{'_data'}{$x_dn};
  my $upper = $self->{'_data'}{$x_up};

  if ( ref $lower || ref $upper )
     {

     return sub
        {
        my $k = shift();

        print "branch: ( $lower $upper )->( $key )\n";

        $lower = ref $lower ? $lower->_value($k) : $lower;
        $upper = ref $upper ? $upper->_value($k) : $upper;

        return mx_plus_b( $key, $x_dn, $x_up, $lower, $upper );
        };

     }
  else
     {

     print "leaf: ( $lower $upper )->( $key )\n";

     return mx_plus_b( $key, $x_dn, $x_up, $lower, $upper );

     }

  }

sub mx_plus_b
  {
  my ( $x, $x_dn, $x_up, $y_dn, $y_up ) = @_;

  my $slope     = ( $y_up - $y_dn ) / ( $x_up - $x_dn );
  my $intercept = $y_up - ( $slope * $x_up );
  my $y = $slope * $x + $intercept;

  return $y;
  }

package main;

use warnings;
use strict;

my $pwlf = pwlf->new;

$pwlf->insert(0, 0);
$pwlf->insert(2, 2);

my $pwlf2 = pwlf->new;

$pwlf2->insert(0, 0);
$pwlf2->insert(2, 4);

my $pwlf3 = pwlf->new;

$pwlf3->insert(0, $pwlf);
$pwlf3->insert(2, $pwlf2);

print $pwlf3->(1)(2), "\n";