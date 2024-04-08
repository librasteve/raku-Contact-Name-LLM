use LLM::Functions;
use LLM::Prompts;
use Text::SubParsers;
use JSON::Fast;
use Data::Dump::Tree;
use Text::CSV;
use Net::Google::Sheets;

my $name = 'reading-c2e-v2';
my $goal = 'upload';
my $live = 'sheet1';

my $session = Session.new;
#$session.check-token;
dd my %sheets = $session.sheets;
my $id = %sheets{$name};

my %active = {
    sheet1 => Sheet.new(:$session, :$id, range => 'Sheet1'),
    sheet2 => Sheet.new(:$session, :$id, range => 'Sheet2'),
};

given $goal {
    when 'upload' {
        ### upload csv to sheet

        my $in = "$*HOME/Downloads/$name.csv";

        my @dta = csv(:$in).Array;
#        @dta = [];
        $sheet2.values: @dta;

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


#`[
my $id = %sheets<AWS_EC2_Sizes>;

# get values from Sheet1
my $sheet1 = Sheet.new(:$session, :$id, range => 'Sheet1');
my $vals = $sheet1.values;
say $vals;
#say $vals[1;*];

# put values into Sheet2
my $sheet2 = Sheet.new(:$session, :$id, range => 'Sheet2');
$sheet2.values: $vals;
#]


