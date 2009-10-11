package foo;

use warnings;
use strict;

use Carp;
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

         return exists $self->{'_pwlf'}{ $key }
              ? $self->{'_pwlf'}{ $key }
              : STORE( $self, $key, {} );
            
         }
      DEFAULT
         {

         ## if *not* in REF context and the key does not exist
         ## interpolate
         
         my $lo_x = 0;
         my $hi_x = 10;
         
         my $lo_y = $self->{'_pwlf'}{$lo_x};
         my $hi_y = $self->{'_pwlf'}{$hi_x};
         
         my $recurse = ref $lo_y || ref $hi_y;
         
         if ( $recurse )
            {
            ## hard part goes here
            }
         else
            {
            return mx_plus_b( $key, $lo_x, $hi_x, $lo_y, $hi_y );
            }

         };

#   
#   ## return undef so perl will auto-vivify
#   if ( ! exists $self->{'_pwlf'}{$key} )
#      {
#      return;
#      }
#
#   my $val = $self->{'_pwlf'}{$key};
#   
#   ## if the value is a reference link it to the current object
#   if ( ref $val )
#      {
#      my $tied_object            = tied %{ $val };
#      $tied_object->{'_up_link'} = { object => $self, key => $key };
#      $self->{'_dn_link'}        = $tied_object;
#      return $val;
#      }
#   else
#      {
#      
#      my $derived_value;
#      
#      my $iter = $self;
#      
#      while ( $iter )
#         {
#         
#         ## be sure the doubly linked list is valid
#                  
#         my $dn_up_obj = $iter->{'_dn_link'}{'_up_link'}{'object'};
#
#         last if $dn_up_obj && $iter != $dn_up_obj;
#         
#         my $up_link = $iter->{'_up_link'};
#         
#         $derived_value += $key;
#
#         $key  = $up_link->{'key'};
#         $iter = $up_link->{'object'};
#
#         }
#         
#      return $derived_value;
#      }

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

$foo{0}  = 0;
$foo{10} = 1;

print $foo{1} . "\n";

use Data::Dumper;

#print Dumper \%foo;

#print $foo{1}{2}{3}{4} . "\n";
