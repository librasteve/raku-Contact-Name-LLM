use LLM::Functions;
use LLM::Prompts;
use Text::SubParsers;
use JSON::Fast;
use Data::Dump::Tree;
use Text::CSV;
use Net::Google::Sheets;

my $name = 'reading-c2e-v2';
my $email = 'Email';
my $full = 'Full name';
my $first = 'First name';
my $last = 'Last name';

#my $goal = 'upload';
#my $goal = 'clear';
#my $goal = 'list';
#my $goal = 'get';
my $goal = 'extract';

my $live = 'sheet2';

my $session = Session.new;
#$session.check-token;
my %list = $session.sheets;
my $id = %list{$name};

my %active = (
    sheet1 => Sheet.new(:$session, :$id, range => 'Sheet1'),
    sheet2 => Sheet.new(:$session, :$id, range => 'Sheet2'),
    sheet3 => Sheet.new(:$session, :$id, range => 'Sheet3'),
);

my @values;

given $goal {
    when 'list' {
        %list.keys.sort.map(*.say);
    }
    when 'upload' {
        my $in = "$*HOME/Downloads/$name.csv";

        my @dta = csv(:$in).Array;
        %active{$live}.values: @dta;
    }
    when 'clear' {
        %active{$live}.clear;
    }
    when 'get' {
        @values = %active{$live}.values;
    }
    when 'extract' {
        @values = %active{$live}.values;

        my %col = @values[0;*] Z=> ^Inf;

        my @data = @values[*;%col{$email}][1..*];

        for @data -> $datum is rw {
            $datum ~~ s:g/'(' .* ')'//;       #rm anything in parens
            $datum ~~ s:g/^ (.*?) '@' .* $/$0/;     #take lhs fo email
        }


        say @data;

#        my @surrogates = 'John Smith', 'Kylie Minogue';

        #my &fe = llm-example-function( to-json(@surrogates) =>
        #    '[{"first_name": "John", "last_name": "Smith"} {"first_name": "Kylie", "last_name": "Minogue"}]'
        #);

#        my &fe = llm-example-function(
#            @surrogates.&to-json =>
#            '[["John", "Smith"], ["Kylie", "Minogue"]]'
#        );

#        my &fe = llm-example-function(
#            ['John Smith', 'Kylie Minogue', 'Mikejennion', 'Andreaglenister'].&to-json =>
#                        '[["John", "Smith"], ["Kylie", "Minogue"], ["Mike", "Jennion"], ["Andrea", "Glenister"]]'  ,
#            hint => 'please convert this list of inputs to first name / last name',
#            hint => 'no, Andreaglenister is wrong, should be Andrea Glenister, and so on',
##            hint => 'Mikejennion is wrong, should be Mike Jennion, and so on',
#
#            #            hint => 'sometimes there is no space between first and last names',
#        );

#        my &fe = llm-example-function(
#            ['John Smith', 'Kylie Minogue', 'Mikejennion', 'Andreaglenister'].&to-json =>
#                '["John", "Kylie", "Mike", "Andrea"]'  ,
#            hint => 'please extract valid first names from this list of inputs',
#            hint => 'no, Andreaglenister is not a valid firstname, should be Andrea, and so on',
##            hint => 'no, Garethaus is not a valid firstname, should be Gareth, and so on',
##            hint => 'Mikejennion is wrong, should be Mike Jennion, and so on',
##            hint => 'sometimes there is no space between first and last names',
#       );
#
#        my @result = &fe( @data[^600].&to-json ).&from-json;


        my &fe = llm-example-function(
            ['tomp', 'Kylie.Minogue', 'Mikejennion', 'Andrea_glenister', 'david-bowie', 'J', 'Db', 'Stevec', 'Fionac'].&to-json =>
                '["Tom", "John", "Kylie", "Mike", "Andrea", "David", "none", "none", "Steve", "Fiona"]'  ,
            hint => 'please extract valid first names from this list of string inputs',
            hint => 'please use the string none if you have no good result',
        );

        my $jump = 64;
        my $last = +@data;

        my @starts = (0, $jump, ($jump*2) ... $last);
        my @ends = @starts.clone.splice(1).push($last).map(*-1);
        my @ranges = @starts Z.. @ends;

        my @culls = <
            Apprentice
            Street
            Newbury
            Commercial
            Comercial
            Info
            lynch
            Abray
            Iblake
            Pmoss
            Arouse
            Sward
            Zwest
            Shop
        >;

        sub do-batch( $r ) {
            say $r;

            my @result = &fe( @data[|$r].&to-json ).&from-json;

            for @result -> $datum is rw {
                for @culls -> $cull {
                    my $regex = rx:i/.* $cull .*/;
                    $datum .= subst( $regex, 'none' );
                }
                $datum .= tc unless $datum eq 'none';
                $datum = 'none' if $datum.chars < 3;
            }

            ddt @result;
        }

#        @ranges.map(*.&do-batch)
        @ranges[*-2].&do-batch;

    }
}



#`[
my @surrogates = 'John Smith', 'Kylie Minogue';

#my &fe = llm-example-function( to-json(@surrogates) => 
#    '[{"first_name": "John", "last_name": "Smith"} {"first_name": "Kylie", "last_name": "Minogue"}]'
#);

my &fe = llm-example-function( to-json(@surrogates) => 
    '[["John", "Smith"], ["Kylie", "Minogue"]]'
);

ddt &fe(to-json(['Keanu Reeves', 'Mark Wahlberg'])).&from-json;
#]




