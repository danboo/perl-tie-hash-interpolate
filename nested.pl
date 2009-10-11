package foo;

use warnings;
use strict;

use Carp;

#$SIG{'__WARN__'} = \&Carp::confess;

use Contextual::Return;

sub TIEHASH
   {
   print "TIEHASH: @_\n";
   my ($class) = @_;
   my $self = { '_pwlf' => {} };
   return bless $self, $class;
   }
   
sub FIRSTKEY
   {
   (undef) = scalar keys %{$_[0]->{'_pwlf'}};
   return each %{$_[0]->{'_pwlf'}};
   }

sub NEXTKEY
   {
   return each %{$_[0]->{'_pwlf'}};
   }

sub EXISTS
   {
   print "EXISTS: @_\n";
   my ($self, $key) = @_;
   return exists $self->{'_pwlf'}{$key};
   }   

sub STORE
   {
   print "STORE: @_\n";
   my ($self, $key, $val) = @_;
   if ( ref $val )
      {
      tie %{ $val }, 'foo';
      }
   $self->{'_pwlf'}{ $key } = $val;
   return $val;
   }   

sub FETCH
   {
   print "FETCH: @_\n";
   my ($self, $key) = @_;
   
   return
      REF
         {

         ## if in REF context and the key does not exist
         ## auto-vivify a nested tied hash

         if ( ! exists $self->{'_pwlf'}{ $key } )
            {
            return STORE( $self, $key, {} );
            }
         else
            {
            
            ## in REF context, if the key exists, we need to return an object
            ## that can unwind a series of STORE calls or a series of
            ## interp calls
            
            my $lo_x = 0;
            my $hi_x = 2;
            
            my $lo_y = $self->{'_pwlf'}{$lo_x};
            my $hi_y = $self->{'_pwlf'}{$hi_x};
            
            print "y-s: $lo_y $hi_y\n";
            
            my $interp = sub
               {
               my $x = shift();

               $lo_y = ref $lo_y ? $lo_y->{$x} : $lo_y;
               $hi_y = ref $hi_y ? $hi_y->{$x} : $hi_y;

               return mx_plus_b( $key, $lo_x, $hi_x, $lo_y, $hi_y );
               };
                 
            my $recurse = ref $lo_y || ref $hi_y;
            
            return $recurse
                 ? $interp
                 : $interp->($key);
               
            
            }
            
         }
      DEFAULT
         {

         ## if *not* in REF context and the key does not exist
         ## interpolate
         
         my $lo_x = 0;
         my $hi_x = 2;
         
         my $lo_y = $self->{'_pwlf'}{$lo_x};
         my $hi_y = $self->{'_pwlf'}{$hi_x};
         
         print "y-s: $lo_y $hi_y\n";
         
         my $interp = sub
            {
            my $x = shift();

            $lo_y = ref $lo_y ? $lo_y->{$x} : $lo_y;
            $hi_y = ref $hi_y ? $hi_y->{$x} : $hi_y;

            return mx_plus_b( $key, $lo_x, $hi_x, $lo_y, $hi_y );
            };
              
         my $recurse = ref $lo_y || ref $hi_y;
         
         return $recurse
              ? $interp
              : $interp->($key);

         };

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

my %foo;

tie %foo, 'foo';

$foo{0}{0}  = 0;
$foo{0}{2}  = 2;
$foo{2}{0}  = 0;
$foo{2}{2}  = 4;

print $foo{1} . "\n";

#use Data::Dumper;

#print Dumper \%foo;

#print $foo{1}{2}{3}{4} . "\n";
