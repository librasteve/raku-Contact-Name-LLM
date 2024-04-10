use LLM::Functions;
use LLM::Prompts;
use Text::SubParsers;
use JSON::Fast;
use Data::Dump::Tree;
use Text::CSV;
use Net::Google::Sheets;

my $name = 'reading-c2e-v2';
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

        my @data = @values[*;%col{$full}][1..*];

        for @data -> $datum is rw {
            $datum ~~ s:g/'(' .* ')'//;       #rm anything in parens
        }


        say @data;


        my %fixes = (
            Garethaus => 'Gareth',
            Db => 'none',
        );


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

        my &fe = llm-example-function(
            ['John Smith', 'Kylie Minogue', 'Mikejennion', 'Andreaglenister'].&to-json =>
                '["John", "Kylie", "Mike", "Andrea"]'  ,
            hint => 'please extract valid first names from this list of inputs',
            hint => 'no, Andreaglenister is not a valid firstname, should be Andrea, and so on',
#            hint => 'no, Garethaus is not a valid firstname, should be Gareth, and so on',
            #            hint => 'Mikejennion is wrong, should be Mike Jennion, and so on',

            #            hint => 'sometimes there is no space between first and last names',
       );

        my @result = &fe( @data[^40].&to-json ).&from-json;

        for @result -> $datum is rw {
            $datum.subst: %fixes;
        }

        ddt @result;
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




