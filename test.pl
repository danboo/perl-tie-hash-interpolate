package foo;

use warnings;
use strict;

use Carp;

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
   }   

sub FETCH
   {
   print "FETCH: @_\n";
   my ($self, $key) = @_;
   
   if ( ! exists $self->{'_pwlf'}{$key} )
      {
      return;
      }

   my $val = $self->{'_pwlf'}{$key};
   
   ## if the value is a reference link it to the current object
   if ( ref $val )
      {
      my $tied_object            = tied %{ $val };
      $tied_object->{'_up_link'} = { object => $self, key => $key };
      $self->{'_dn_link'}        = $tied_object;
      return $val;
      }
   else
      {
      
      my $derived_value;
      
      my $iter = $self;
      
      while ( $iter )
         {
         
         ## be sure the doubly linked list is valid
                  
         my $dn_up_obj = $iter->{'_dn_link'}{'_up_link'}{'object'};

         last if $dn_up_obj && $iter != $dn_up_obj;
         
         my $up_link = $iter->{'_up_link'};
         
         $derived_value += $key;

         $key  = $up_link->{'key'};
         $iter = $up_link->{'object'};

         }
         
      return $derived_value;
      }

   }
   
package main;

use warnings;
use strict;

my %foo;

tie %foo, 'foo';

$foo{1}{2}{3}{4} = 1;

use Data::Dumper;

#print Dumper \%foo;

print $foo{1}{2}{3}{4} . "\n";
