package PDF::Reuse::Tutorial;

use 5.008;
use strict;

our $VERSION = '0.02';

1;
__END__

=head1 NAME

PDF::Reuse::Tutorial - How to produce PDF-files with PDF::Reuse

=head1 DESCRIPTION

In this tutorial I will show some aspects of PDF::Reuse, so you should be able
to use it in your own programs. Most important is how to produce and B<reuse> PDF-code,
and then if you are interested, you can look at Graphics and JavaScript, so you can
to do special things.


=head3 Reusing code:

You can take advantage of what has been done before, it is not necessary to start
from scratch every time you create a PDF-file. You use old PDF-files as a source for
forms, images, fonts and texts. The components are taken as they are, or rearranged, 
and you add your own texts and you produce new output. 

If you don't care too much about the size of your templates, you should make them 
with a commercial, visual tool, that's most practical; and then you should use 
PDF::Reuse to mass produce your files. In this tutorial I show in many places
how create single files with PDF::Reuse. That is possible, but more of an exception.
I do it here to show the technique. You will anyway need it to add texts and graphics
to your templates.   

=head3 Graphics:

With this module you get a good possibility to program directly with the
basic graphic operators of PDF. This is perhaps an advanced level, and you can
avoid it if you want. On the other hand, it is not very difficult, and if you take
advantage of it, your possibilities to manage text and graphics increase very much.
You should look at the "PDF-reference manual" which probably is possible to download from
http://partners.adobe.com/asn/developer/acrosdk/docs.html.
Look especially at chapter 4 and 5, Graphics and Text, and the Operator summary.

Whenever the function prAdd() is used in this tutorial, you can probably get more
explanations in the "PDF-reference manual". The code, you add to the content
stream with prAdd(), has to follow the PDF syntax completely.

=head3 JavaScript:

You can add JavaScript to your PDF-file programmatically. This is experimental, but I
think it can work very well anyway, at least with Acrobat Reader 5.1 or Acrobat 5.0.
I can't give any guarantees about future versions.
You should have the "Acrobat JavaScript Object Specification" by hand. If you
haven't got Acrobat, you can probably download it from http://partners.adobe.com/asn/developer/technotes/acrobatpdf.html.
It is technical note # 5186. 
JavaScript for HTML and PDF differs so much that you need the manual, even if
you know JavaScript very well.

  

I have developed PDF::Reuse in a Windows environment, so I don't use the line

    #!/usr/bin/perl -w

It only produces an warning that it's too late for this switch. If you work under
Unix you probably have to add that to all the examples

=head2 A very basic program
   
   # ex1_pl

   use PDF::Reuse;                       # Mandatory  
   prFile('ex1.pdf');                    # File name is mandatory
   prText(250, 650, 'Hello World !');       
   prEnd();                              # Mandatory

A file name is necessary. The line with prText is a directive to put a text 250 pixels
to the right and 650 pixels up. If you haven't stated anything else the font will be
Helvetica and 12 pixels, the page format will be 595 pixels wide and 842 pixels high.
Later on you will see how to change that. There are many other default values.

If you skip the line with prText, you get an empty page. In fact that can be very
useful if you want to work with JavaScript.

The last line is also necessary to write page structure and other things to the disc
and to close the current file.

=head2 Page breaks

    # ex2_pl

    use PDF::Reuse;
    use strict;                            

    prDocDir('doc');                           # Document directory
    prFile('long.pdf');
    prFont('Courier-Bold');                    # Sets font  
    prFontSize(20);                            # And font size  
    for (my $i = 1; $i < 10001; $i++)                 
    {   prText(250, 650, "This is page $i");       
        prPage();                              # Page break
    }
    prEnd();                               

This little program gives you a hint why I wrote the module as functional. It is slow to start,
because the module is big, but then it should be fast. On my old computer it defines at least
a thousand pages per second, and the capacity should be sufficient. You can easily
increase the number of pages to 100 000.


=head2 Small files

This program is not as fast as the previous one. It is internally more complicated.
On my PC with Windows, it also seems like the operating system needs much
time to catalogue each file. 

    # ex3_pl

    use PDF::Reuse;
    use strict;                            

    prDocDir('doc');                         

    for (my $i = 1; $i < 1001; $i++)                 
    {   prFile("short$i.pdf");
        prFontSize(16);                      
        prFont('Times-Bold');                          
        prText(180, 650, 'This is the first and only page');                                                    
    }
    prEnd();

Here we produce 1000 documents. When you define a new file the old one is automatically written. You have to set font and font size for each
file if you are not satisfied with Helvetica 12.      


=head2 Starting to reuse 

Now we come to a real reason why PDF::Reuse is needed. It gives you a possibility to reuse pages from
a PDF-file as a form or background. It can be used as a template. 

In this example we are going to send a letter (a physical letter to be printed) to
some of our customers. We imagine that the vice president will give some views about what happened
last year. First he writes a letter in Word. It is converted to PDF. That is done
by a plug in, PDFMaker, which you get when you buy Adobe Acrobat. (Look at next example
if you want to do everything with PDF::Reuse directly. Then you get a better result. But a vice president wouldn't 
work like that. He would like to use a tool like Word. He knows it and it's convenient, and that's
also ok.) Anyway, when PDFMaker has generated the file, you have to do a little trick.
(If it is an important file, take a copy of it first.)
You open the file in Acrobat. Choose the TouchUp tool for text, and remove 1 letter
e.g. 1 space, then insert the same letter and save the file. By doing so, you will
fool Acrobat to concatenate all streams of the page. It can then be transformed
to an "XObject", which is a very practical format. PDF::Reuse can now use it as a background
or template.

When you downloaded the module I hope you also got 'lastYear.pdf' which is the PDF-file
that is the template for the letter. A little text file holds names and addresses.
In reality these things should be taken from a database, and you could produce a file
for many thousand customers.  

    # ex4_pl
    
    use PDF::Reuse;
    use strict;
    my $line;
    my $step = 14;

    prDocDir('doc');
    prFile('Letter.pdf');
    prFont('Times-Roman');
    prCompress(1);     

    my $infile = 'persons.txt';
    open (INFILE, "<$infile") || die "Couldn't open $infile, $!\n aborts!\n";
    while ($line = <INFILE>)
    {    my ($fName, $lName, $co, $street, $zipCode, $city, $country) = split(/,/, $line);
         my $y = 760;
         my $x = 105;
         prForm('lastYear.pdf');                # Here the template is used
         prText($x, $y, "$fName $lName");
         $y -= $step;
         if ($co)
         {   prText($x, $y, $co);
             $y -= $step;
         }
         prText($x, $y, $street);
         $y -= $step;
         prText($x, $y, $zipCode);
         prText(($x + 50), $y, $city);
         $y -= $step;
         prText($x, $y, $country);

         prText(107, 660, "Dear $fName $lName");
         prPage();
    }
    prEnd();
    close INFILE;         

Look at the template. It is 50 kB and the file we just produced has 5 pages, using
the template on every page. Yet our new file is only 43 kB. It looks a little bit
confusing. PDF::Reuse only used something like 41 kB of the template. It was defined
once and then the "PDF-code" referred to it, each time it was used. You can get
very compact lists in this way. Try with a template of your own and several
thousand customers, and you will see that this an excellent way of producing
long lists in a very compact format.

If you would had needed some bars for an enveloping machine, you could had added
a snippet of code just before prPage(). Here we use the graphic operators of PDF.
We put the code in a string, and add it to the "content stream" of the current page.
Study the PDF Reference Manual and do some experiments if you want to use it. ( I
don't remember exactly the distances between the bars, but it could be something
like this.) 

         my $string = "q\n";         # save graphic state
         $string   .= "4 w\n";       # make line width 4 pixels
         $string   .= "10 600 m\n";  # move to x=10 y=600, starts a new subpath
         $string   .= "40 600 l\n";  # a line to x=40 y=600 ( a horizontal line)
         $string   .= "10 580 m\n";   
         $string   .= "40 580 l\n";   
         $string   .= "10 510 m\n";   
         $string   .= "40 510 l\n";
         $string   .= "s\n";         # close the path and stroke
         $string   .= "Q\n";         # restore graphic state
         prAdd($string);             # the string is added to the content stream

If you think it is too complicated to program the bars, you could have painted 
them in some program and added them to the word-document.(That would also have
been better, because you would have had the bars defined only once in the document,
and not on every page.)   

=head2 A variation of previous example

Ok, if you want to avoid commercial tools like Word and Acrobat, you have to work
a little bit harder, but it is possible to get a better result.

This time we produce the template also. In the distribution you received a little text file
'Lastyear.txt' and a little jpeg-image with the signature of the vice president.
You also need Image::Info.

    # ex5_pl
    
    use PDF::Reuse;
    use Image::Info qw(image_info dim);        # To get the dimensions of jpeg-images
    use strict;

    my $textFile = 'Lastyear.txt';
    my $file     = 'patric.jpg';     # image with a signature
    my $x        = 107;              # left margin
    my $y        = 646;              # Start 646 points up 
    my $step     = 15;               # Distance between lines (fontsize = 12)

    prDocDir('doc');

    prFile('LetterB.pdf');
    prCompress(1);                   #  Compress the stream
    prFont('Times-Roman');       

    open (INFILE, "<$textFile") || die "The text $textFile couldn't be opened, $!\n";

    while (my $line = <INFILE>)
    {   chomp $line;
        if ($line eq 'Yours sincerely')          # It's time to insert the image 
        {  my $info  = image_info($file);
           my ($width, $height) = dim($info);    # Get the dimensions
           my $intName = prJpeg("$file",         # Define the image and get
                                 $width,         # an internal name
                                 $height);
           #############################################################################
           #  The signature image happened to become a little too big when I made it   #
           #  So I have to scale it down for the sentence where it is shown            #
           #############################################################################

           $width  = $width  * 0.6;                     # Scale it down
           $height = $height * 0.6;                     # Scale it down
           my $yImage = $y - 25;                        # Put the image lower down
           $x += 50;                                    # Indent from now on
       
           #############################################################################
           #  Now we have to add something to the content stream to make the newly     #
           #  defined image visible. This is one possibility                           #
           #############################################################################
     
           my $string = "q\n";                                # save graphic state
           $string   .= "$width 0 0 $height $x $yImage cm\n"; # add numbers to the
                                                              # transformation matrix
           $string   .= "/$intName Do\n";                     # paint the image
           $string   .= "Q\n";                                # restore graphic state 

           prAdd($string);                     # Here we add the graphic directives  
                                              # to the content stream                        
        }

        prText($x, $y, $line);                # A simple way to handle text                       
        if ($y < 40)
        {  prPage();
           $y = 830;
        }
        else
        {  $y -= $step;
        }
    }    
 
    close INFILE;
    prEnd;  

This template will be smaller than 5 kB. The produced letters could also be sent by
e-mail.

=head2 Usual business documents.

PDF::Reuse has enough speed to produce ordinary business documents like order forms,
receipt, contracts etc. They can be displayed on practically every computer, and if
you pay a little attention to it, they should be small enough, so you can send them
over the net. As an extra plus, you can get a log, which can be used for
archiving or verification of the documents. Usually the log should be much smaller 
than the formatted document. If you have big templates or images the log can be a 
few percent or fractions of a percent of the document. (If that is too much for you,
it is possible to compress it physically or "logically" even more.)

First we design a template for the receipt. We do it in Word and the PDFMaker converts
it to PDF. As usual we have to remove 1 space and put it back to concatenate the streams
You should have 'receipt.pdf' in the distribution. It is 46 kB big. It can be used
as it is, but to me it is a little bit too big.

=head2 Making a small template

You can skip this example, if you think 46 kB is a good size for the template for
receipts.

I reuse 1 font from the previous example, and rewrite the template to get it smaller.
You need PDF::API2::Util to get a color. If you haven't got that module, you could
use '0 0 0.9333' as blue2.
In the distribution there is a program 'reuseComponent_pl'. Run it to see the
names of included fonts: 

   perl reuseComponent_pl receipt.pdf

and you get 'myFile.pdf'. (The program needs the module PDF, which is totally
independent of PDF::Reuse. PDF sometimes croaks about 'bad object reference >'
when the info-part of the PDF-file is missing. That doesn't hinder 'myFile.pdf'
from being created.)  

    # ex6_pl

    use PDF::Reuse;
    use PDF::API2::Util;          
    use strict;

    prDocDir("doc");

    my @c = namecolor('blue2');
  
    prFile("ReceiptSmall.pdf");
    prCompress(1); 
   
    prForm( { file   => 'Receipt.pdf',              # Just to get the definitions
              page   => 1,                          # from the page, and not to
              effect => 'load' } );                 # add anything to the page

    my $intName = prFont('FJIILK+Serpentine-Bold'); # "Extract" the font and get a
                                                    # name to use in the stream 
 
    my $string = "q\n";                             # save graphic state
    $string   .= "BT\n";                            # Begin Text
    $string   .= "/$intName 1 Tf\n";                # set font and "size" 
    $string   .= "40 0 0 40 85 784 Tm\n";           # set a text matrix
    $string   .= "-0.05 Tc\n";                      # set character spacing
    # $string   .= "0 Tw\n";                        # set word spacing
    $string   .= "$c[0] $c[1] $c[2] rg\n";          # set color for filling
    $string   .= "(Gigantic Electric Inc.) Tj\n";   # show text
    $string   .= "ET\n";                            # End Text
    $string   .= "Q\n";                             # restore graphic state

    prAdd($string);                                  
    
    prFont('TR');
    prFontSize(18);
    prText(153, 758, 'Everything electrical for home and office');
    prText(167, 702, 'Receipt');
    prFontSize(14);
    prText(120, 665, 'Customer');
    prText(120, 649, 'Address');
    prText(120, 633, 'City');
    prText(120, 617, 'Phone');
    prText(335, 665, 'Seller');
    prText(335, 649, 'Cashier');
    prText( 78, 568, 'Item');
    prText(445, 568, 'Sum');
    prText(508, 568, 'Delivery');
    prAdd("q 0 95 m 700 95 l S Q");                  # draw a horizontal line
    prFontSize(9);
    prText(72, 79, 'Main Office');
    prText(72, 69, 'Box 99999');
    prText(72, 59, 'Stora Allén 99');
    prText(72, 49, 'SE-19999 Stockholm');
    prText(72, 39, 'Phone +46-8-99999999');
    prText(264, 79, 'Shop (This Subsidiary)');
    prText(264, 59, 'Breda Allén 99');
    prText(264, 49, 'SE-15999 Skärholmen');
    prText(264, 39, 'Phone +46-8-19999999');
    prText(432, 79, 'VAT SE-559999-9999');

    prEnd();

Now your template will be 4,84 kB. If that still is too big for you, you can replace
  
    prForm( { file   => 'Receipt.pdf', 
              page   => 1,
              effect => 'load' } );

    my $intName = prFont('FJIILK+Serpentine-Bold');

with this sentence

    my $intName = prFont('HB');

Then the template will be 1,22 kB. But then you might get the wrong font for
the company name, and you should adjust the text matrix so you get the text a little
better centered and so on. Perhaps this text matrix would make it better:

    $string   .= "50 0 0 38 75 784 Tm\n";

=head2 Using the template

In this example we use the template and print a receipt similar to one that I received
some time ago. That one was printed with a little printer with at least 3 carbon copies and
without barcodes. At the same time I received a special guarantee for one of the items.
(I haven't done the guarantee certificate here). Anyway all of this could be done as
PDF-files, which are easy to send over the net, and with the additions of a log 
and barcodes they should be easy to store, restore and handle.

In a real situation all data should be taken from an interactive program or a database. Here
I have assigned everything directly in the program.

The barcodes have not been really tested. 

    # ex7_pl

    use PDF::Reuse;
    use Digest::MD5;
    use GD::Barcode::Code39;
    use strict;

    my $itemLines  = 550;             # start to write item lines 550 pixels up
    my $pageBottom = 100;

    my $str;
    ###############################
    # Columns for the item lines
    ###############################
    my $x0         = 41;
    my $x1         = 43;
    my $x2         = 337;
    my $x3         = 400;
    my $x4         = 470;
    my $x5         = 477;
    my $x6         = 506;               
    my $y          = $itemLines;                      
    my $step       = 12;               # Distance between lines (fontsize = 10)
    my $width      = 5.83;             # character width (approx 7/12 * fontsize ? )
    my $pageNo;
    my $form       = 'ReceiptSmall.pdf';

    prDocDir('doc');
    prLogDir('run');           # To get a log

    prFile('ex7.pdf');
    prTouchUp(0);                      # So you can't change it by mistake
    prCompress(1);
    prForm($form);

    my $now = localtime();
    my @tvec = localtime();
    my $today = sprintf("%02d", $tvec[5] % 100)  . '-'
              . sprintf("%02d", ++$tvec[4])      . '-'
              . sprintf("%02d", $tvec[3]);
 
    my $customer  = 'Anders Svensson';
    my $address   = 'Klämgränd 9';
    my $city      = 'Stockholm';
    my $phone     = '9999999';
    my $seller    = 'Alex Buhre';
    my $cashier   = 'Ritva Axelsson';
    my $refNo     = '123456789';
    my $paid      = '3599.00';
    my $payMethod = 'MC/EC 544819999999999999999';
    my $sum;

    my @items = ( [1, '22292 Microsoft Xbox Sega/Jsrf', 1, 2541, $today, 
                  '      Guarantee, ref No 345678,  is attached'],
                  [2, '20503 Microsoft Project Gotham', 1, 55, ' ',
                  '      To be fetched later by the customer'],
                  [3, '20508 TV-Spel Hårdv DVD-Adapt/Fjärr', 1, 346, $today],
                  [4, '21964 EA Game       SIMS Unleashed', 1, 319, $today],
                  [5, '22249 Nordisk CD/MC/Spelfil Spiderm', 1, 239, $today],
                  [6, '21660 Sony    Videoband 3E-24oV-ORG-EUR', 1, 99, $today]
                );
  
    pageTop();

    prFont('C');
    prFontSize(10);

    for my $item (@items)
    {  my @detail = @$item;
       ra($x0, $y, "$detail[0]." );
       prText($x1, $y, $detail[1] );
       ra($x2, $y, $detail[2]); 
       my $price = sprintf("%.2f", $detail[3]);
       ra($x3, $y, $price);
       my $itemSum = ($detail[2] * $detail[3]);
       $sum += $itemSum;
       $itemSum = sprintf("%.2f", $itemSum );
       ra($x4, $y, $itemSum);
       prText($x5, $y, 'SEK');
       prText($x6, $y, $detail[4]);
   
       if (defined $detail[5])
       {   $y -= $step;
           prText($x1, $y, $detail[5]);
       }
       $y -= $step;
       if ($y < $pageBottom)
       {   pageEnd();
           prPage();
           prForm($form);
           $y = $itemLines;
       }
    }

    my $vat = $sum * 0.25;
    prText($x2 - 12, $y, '(Included VAT');
    $vat = sprintf("%.2f", $vat);
    ra($x4, $y, $vat);
    prText($x5, $y, 'SEK)');
    $y -= $step;
    prText($x2, $y, 'Sum to pay');
    $sum = sprintf("%.2f", $sum);
    ra($x4, $y, $sum);
    prText($x5, $y, 'SEK');
    $y -= $step;
    prText($x1, $y, "Paid      $payMethod");
    ra($x4, $y, $paid);
    prText($x5, $y, 'SEK');
    pageEnd();

    prEnd(); 

    ##########################################################################
    #  Subroutine to right adjust and print
    ##########################################################################
    sub ra                         
    {  my ($X, $Y, $str) = @_;
       $X -= (length($str)* $width);
       prText($X, $Y, $str);
    }

    ##########################################################################
    #  To print before the end of the page
    ##########################################################################
    sub pageEnd
    {  $y -= $step * 4;
       prText($x1, $y, "Ref No $refNo");
       my $oGdB = GD::Barcode::Code39->new($refNo);
       my $str = $oGdB->barcode();
       prFontSize(17);
       prBar(200, $y, $str);
       prFontSize(10);
       prFont('C');
       prText(($x3 + 30), $y, 'Check No Method: S1');
       $y -= $step;
       my $str2 = prGetLogBuffer() . '436';
       prLog('<S1>');
       $str = Digest::MD5::md5_hex($str2);
       prText($x1, $y, "Check No $str");
    }
   
    sub pageTop
    {  $pageNo++;
       prFont('Times-Roman');
       prFontSize(18);
   
       prText(230, 702, "$now  Page: $pageNo");
   
       prFontSize(14);
       prText(180, 665, $customer);
       prText(180, 649, $address);
       prText(180, 633, $city);
       prText(180, 617, $phone);
       prText(386, 665, $seller);
       prText(386, 649, $cashier);
    }

When I run this program with the template of 4,84 kB the final file was 6,95 kB.  
In this special case the log was 2,07 kB and compressed 1,00 kB. It would have had
practically the same size if you had used the template of 46 kB.

Note the sentence

     prTouchUp(0);

It more or less "disables" the TouchUp tool in Acrobat. It makes it difficult to change
the document by mistake. Still you can save the document as postscript, distill it
and change whatever you want. But now you have had to put some effort in to it, and 
hopefully you have not had access to my log and you should not know how the check 
numbers are calculated, so it would anyway be difficult to falsify. (Also
the barcodes change from a font to pure graphics if you redistill the page.)

This is the way the check number is calculated

       my $str2 = prGetLogBuffer() . '436';
       prLog('<S1>');
       $str = Digest::MD5::md5_hex($str2);
       prText($x1, $y, "Check No $str");

prGetLogBuffer() returns what has been logged for the current page. This could be
an alternative to accumulating all variables.(The log buffer is 
written to the disc and undefined after every page break. Also you need to have a 
log. It is only activated when you have given a log directory with the function
prLogDir.)  The program concatenates the string from the buffer with a fixed
string, '436', which someone has decided should be used in this check number method.
After that, prLog puts a tag, <S1>, in the log. Now a hexadecimal digest is produced
and printed.  With this check number method you need the log to verify that a document
is consistent. If that is good or not depends on your needs.


=head2 Restoring a document from the log

If you have big templates or images in your documents, it might be more practical
to store the logs instead of the formatted documents. The difference in size
can be very big. In the previous example the difference was very small, but I will
anyway show how to restore the document.
To run this program, you have to give the name of the log from previous example 
as an argument. 
The new files are put in new directories to avoid confusion.

   # ex8_pl

   use PDF::Reuse;
   use Digest::MD5;
   use strict vars;

   my $line;
   my $inFile = shift || 'run/ex7.pdf.dat';            # The name of the log

   prDocDir('doc2');
   prLogDir('run2');

   open (INFILE, "<$inFile") || die "Couldn't open file $inFile, $! \n";

   while (chomp($line = <INFILE>))
   {   my @elem = split /~/, $line;
       my $routine = 'PDF::Reuse::pr' .  (shift @elem);
       for (@elem)
       {  s'<tilde>'~'og;
       }
       if ($line eq 'Log~<S1>')
       {  my $str2 = prGetLogBuffer() . '436';
          my $str  = Digest::MD5::md5_hex($str2);
          print "$str\n";
       } 
       &$routine (@elem); 
   }

   close INFILE;
   prEnd();


If you are not interested in the check number, you can remove these lines:

       if ($line eq 'Log~<S1>')
       {  my $str2 = prGetLogBuffer() . '436';
          my $str  = Digest::MD5::md5_hex($str2);
          print "$str\n";
       } 

If you want to use the possibility to restore documents, always
test a little first, to see that it works for your cases also. I have tried to
avoid errors, but you never know ...
(If there is a need, it would be easy to make a program that checks the restored
documents and the originals, to see that there are not any differences.)

In the log there is often a line like this : 'Cid~1042639354'. It is the time stamp
of the following PDF-file or JavaScript. If you try to restore a document and the
source files have changed, you will have an interruption of the run, the program
will die. If you know that the changes in the source file doesn't affect
the final document, just remove the line 'Cid~1042639354' and try
again.

=head2 Other languages than Perl

As the previous example showed, you can have batch routines to create PDF-files.
You let your Cobol program, or what ever it is, create an ASCII file with 
instructions similar to those of the log file (skip all unusual directives
like Cid, Vers, Id and Idtyp) and let some perl program similar to ex8_pl
interpret the instructions.  

Also if you have an application in some other language than Perl, and that application
can write ASCII characters to STDOUT, and your operating system supports pipes,
I think you could let the receiving program, the end of the pipe look like this:

   # ex9_pl
   
   use PDF::Reuse;
   use strict vars;

   my ($line, $routine, @elem);

   chomp($line = <STDIN>); 
  
   while ($line)
   {   @elem = split /~/, $line;
       $routine = 'PDF::Reuse::' . (shift @elem);
       for (@elem)
       {  s'<tilde>'~'og;
       }
       &$routine (@elem);
       chomp($line = <STDIN>) 
   }

And here is a Perl program that writes to STDOUT, but it could be any language

   # ex10_pl

   use strict;

   # Getting customer data in some way ...

   my @custData = ( { firstName => 'Anders',
                      lastName  => 'Wallberg' },
                    { firstName => 'Nils',
                      lastName  => 'Versen' },
                    { firstName => 'Niclas',
                      lastName  => 'Lindberg' },
             
                    # and 10000 more records

                    { firstName => 'Sten',
                      lastName  => 'Wernlund' } );

   print "prDocDir~doc\n";
   print "prFile~piped.pdf\n";
   print "prFont~TR\n";

   for my $customer (@custData)
   {    print "prForm~lastYear.pdf\n";
        print "prText~105~685~Dear $customer->{'firstName'}\n";
        # ...
        print "prPage\n";
   }
   print "prEnd\n";


When I put them in a pipe like this:

   C:\temp>perl ex10_pl | perl ex9_pl

I get a PDF-file with the name 'piped.pdf' in the directory doc.

You can do very many things with a simple pipe like this, but you cannot let
the programs interact, then you need better interprocess communication. 
If you need e.g. an internal name for a "name object", then it is most 
easy to use only Perl and one single program.

An advantage with pipes or daemons is that you can get very good response times.

=head2 Using PDF::Reuse from JScript/VBScript

This little section is specific for Windows and is about how to make a very
simple COM/ActiveX wrapper around PDF::Reuse.

You need to have PerlScript installed on your computer. Read the User Guide that 
comes with ActivePerl to see how that is done. 
You also need the Windows Scripting Host (WSH), Windows Script Components,
Windows Script Component Wizard, Windows Script Runtime, VBScript, JScript,
Microsoft Windows Script Control and probably also documentation. Get all of 
it from the download section at http://msdn.microsoft.com/scripting.

To create a Windows Script Component, follow the instructions in ActivePerl
User Guide - Windows Scripting - Windows Script Components - Ten Easy Steps or
do like this:

     Run the Wizard (when I downloaded it, I received the Scriptlet Wizard)
     Enter a name
     Enter a location
     Click on Next
     Choose run on Server
     (If it is possible, choose PerlScript)
     Click on Next
     Click on Next (If you don't want to define a property)
     Enter "act" under method name
     Enter "string" as parameter name
     Click on Next
     Click on Finish
     
Now you could have something that looks a little like this (The ClassID 
should differ):

    <scriptlet>

    <Registration
        Description="PDFReuse"
        ProgID="PDFReuse.Scriptlet"
        Version="1.00"
        ClassID="{6ede1a17-839b-4220-83e3-ac2ad44a45f5}"
    >
    </Registration>

    <implements id=Automation type=Automation>
        <method name=act>
            <PARAMETER name=string/>
        </method>
    </implements>

    <script language=VBScript>

    function act(string)
        act = "Temporary Value"
    end function

    </script>
    </scriptlet>


Now replace "VBScript" with "PerlScript" and replace the function with 
Perl code so it looks something like this:

    <scriptlet>

    <Registration
        Description="PDFReuse"
        ProgID="PDFReuse.Scriptlet"
        Version="1.00"
        ClassID="{6ede1a17-839b-4220-83e3-ac2ad44a45f5}"
    >
    </Registration>

    <implements id=Automation type=Automation>
        <method name=act>
            <PARAMETER name=string/>
        </method>
    </implements>

    <script language=PerlScript>

         use PDF::Reuse;
         use strict vars;

         sub act
         {  my $line = shift;
            my ($routine, @elem);
            @elem = split /~/, $line;
            $routine = 'PDF::Reuse::' . (shift @elem);
            for (@elem)
            {  s'<tilde>'~'og;
            }
            my @vector = &$routine (@elem);
            if (defined @vector)
            {  my $outString = join('~', (@vector));
               return $outString;
            } 
            else
            {  return '';
            } 
          }

    </script>
    </scriptlet>

Save the file and right-click on the file name from the explorer, and choose
"Register"
Now you should be able to run "PDF::Reuse" from VBScript, JScript and perhaps also
other languages which can handle COM/ActiveX objects. You send the parameters
in a ~-separated string and receive the return value in a similar way. (If you
want to run programs like ex23_pl, you have to write specialized COM-objects.)

This is an example in VBScript:
    
    ' Test.vbs
    ' Use PDF::Reuse from VBScript
    '
    Dim pgm
    Dim ans
    Set pgm = CreateObject("PDFReuse.Scriptlet")
        ans = pgm.act("prFile~fromVB.pdf")
        ans = pgm.act("prForm~lastYear.pdf")
        ans = pgm.act("prText~107~685~Mr Vladimir Bosak")
        ans = pgm.act("prEnd")

Run it from the command line with >cscript Test.vbs or double-click on it from 
the explorer. Here is the same example in JScript

    // Test.js
    // Use PDF::Reuse from JScript
    //

    var pgm = new ActiveXObject("PDFReuse.Scriptlet")
    var ans = pgm.act("prFile~fromJS.pdf")
        ans = pgm.act("prForm~lastYear.pdf")
        ans = pgm.act("prText~107~685~Mr Java Script")
        ans = pgm.act("prEnd")

Here is an example of how to use it from the Internet Explorer. Probably
it is not a very practical example.

    <HEAD><TITLE>A Simple First Page</TITLE>
    <SCRIPT LANGUAGE="JScript">
    <!--
    function Button1_OnClick()
    {  var pgm = PDFREUSE;
       var ans = pgm.act("prFile~C:/Temp/temp/fromHTML.pdf");
           ans = pgm.act("prForm~C:/Temp/temp/lastYear.pdf~1~1");
           ans = pgm.act("prText~107~685~Mr JavaScript HTML");
           ans = pgm.act("prEnd");
    }
    -->
    </SCRIPT>
    </HEAD>
    <BODY>
    <OBJECT ID=PDFREUSE WIDTH=1 HEIGHT=1 
    CLASSID='CLSID:6ede1a17-839b-4220-83e3-ac2ad44a45f5'>
    </OBJECT>
    <H3>A Simple First Page</H3><HR>
    <FORM><INPUT NAME="Button1" TYPE="BUTTON" VALUE="Click Here" 
       onClick=Button1_OnClick()>
    </FORM>
    </BODY>
    </HTML>

Change the directories (and CLASSID) so it can be run on your machine
If something goes wrong and it is within the control of PDF::Reuse, you 
get an error log on the desktop.

The first time you run via an ActiveX object, it is fairly slow, but if you
do it repeatedly, the performance is quit acceptable.

=head2 Importing an image

The best way to import an image, is to take it from  another PDF-file:

   # ex11_pl

   use PDF::Reuse;
   use strict;

   prFile('doc/ex11.pdf');
   prMoveTo(75, 645);                  # Where to put the image
   prScale(0.6, 0.6);                  # Scale the image
   prImage('doc/LetterB.pdf', 1);      # Take an image from page 1
    
   prEnd();

Alternatively you could put the parameters for prImage in a hash:

   # ex12_pl

   use PDF::Reuse;
   use strict;

   prFile('doc/ex12.pdf');
   prMoveTo(75, 645);
   prScale(0.6, 0.6);
   prImage( 
             {  file    => 'letterB.pdf',
                page    => 1,
                imageNo => 1
             } 
          );
    
   prEnd();

Use reuseComponent_pl to see which images you can take from a PDF-file.

(If you would have used 'lastYear.pdf' instead of 'letterB.pdf' in ex11_pl or
ex12_pl you would have had the image reversed when you extract it. PDFMaker
defines it like that, I don't know why. Perhaps life is not supposed to be
too easy. It would have been necessary to reverse the image with the 
transformation matrix.)  

=head2 Adding a document

You can add a document with many pages to the current document with the function
prDoc() like this:

    # ex13_pl

    use PDF::Reuse;
    use strict;

    prFile('doc/ex13.pdf');
    prForm('ex1.pdf');
    prText(100, 500, 'This is put on the first page');
    prPage();
    prDoc('doc/piped.pdf');
    prPage();
    prForm('ex1.pdf');
    prText(100, 500, 'This is put on the last page');

    prEnd();

The document from previous example is used for the first and last pages. In between
a document, with all of its pages, is put. Graphic, and for the first prDoc or prDocForm also interactive, 
functions are included. As usual you loose outlines, info and metadata which I haven't
implemented.

prDoc() is a little bit like a spare routine. You can include "complete" documents
with it and it is not sensitive to the structure of the pages. Each page can
consist of many streams. But you cannot influence the layout of the included pages
in any other way than through JavaScript, and you cannot write anything to the pages.
Also the routine is a little bit slow, but it has a positive
side-effect: If you use it with old PDF-files which have been updated many
times, it only takes the current parts of the files, so the result can be trimmed down. 

=head2 A business card

A PDF-page can often be used as a unit. You can resize it and display it many times
on a new page. For this example I designed a little page with Mayura Draw. (When this text was 
written, you could download the program from http://www.mayura.com and evaluate it for 30 days.) It produces
files in a variant of postscript which can be transformed to PDF by the distiller.
If you want, you can also get PDF-files directly from Mayura Draw, but the files might
become a little big, because it doesn't compress images. 

In the code below you produce 10 cards per page of paper. You print the cards on a 
special paper where each card should be 89 * 51 mm. (I suppose that is close to
253.2584 * 145.126 pixels) The cards start 43 pixels from the left and 59.76 from
the bottom.

Make a PDF-file with your name, photo and so on and replace 'myFile.pdf' with the 
name of your file. You get the best results if the proportions of your file is
something like 89/51 (width/height), but that is not so important. If you haven't
got a photo, you can remove the if..else sentence. Then you can let the x and y-axes
be scaled independently.

    # ex14_pl

    use PDF::Reuse;
    use strict;

    my $y    = 59.76;                  # Margin at the bottom
    my $col1 = 43;                     # First column    
    my $col2 = 296;                    # Second column
    my $step = 145.126;                # Height of the card
    my $string;

    prDocDir("doc");
    prFile('BizCard.pdf');

    my @vec = prForm ( {file   => 'myFile.pdf', # Add the form definitions
                        effect => 'add' }       # and get data about the form
                     );
    ###########################################################################
    # The list from prForm contains $internalName, $lowerLeftX, $lowerLeftY,
    # $upperRightX, $upperRightY, $numberOfImages
    ###########################################################################

    my $form = $vec[0];                       
    my $xScale = 253.2584 / ($vec[3] - $vec[1]);
    my $yScale = 145.126 / ($vec[4] - $vec[2]);
    if ($xScale < $yScale)
    {  $yScale = $xScale;
    }
    else
    {  $xScale = $yScale;
    }
    while ($y < 720)
    {   $string .= "q\n";
        $string .= "$xScale 0 0 $yScale $col1 $y cm\n";  # scale and "move to" 
        $string .= "/$form Do\n";
        $string .= "Q\n";
        $string .= "q\n";
        $string .= "$xScale 0 0 $yScale $col2 $y cm\n";  # scale and "move to"
        $string .= "/$form Do\n";
        $string .= "Q\n";
        $y += $step;
    }
    prAdd($string);   
    prEnd();
 

When you call prForm(), you get an internal name of the form, and then you can use
this name together with the primitive PDF-operators. Acrobat or Acrobat Reader will
understand what you are referring to.    

=head2 Defining interactive fields programmatically

The "normal" way to define interactive fields, is to use Acrobat as a screen
painter. You draw your fields, write your JavaScript, or cut and paste, and so
on. It is convenient for single files, but if you are going to produce thousands
of files, which are not going to look exactly the same, it is not very pracical.
I guarantee you get tired very quickly.

Then it is better to do the job programmatically. Here is an example:

You need an Acrobat JavaScript which defines some fields. It can look like
this:

   // script1.js

   function nameAddress(page, xpos, ypos)
   {  var thePage = 0;
      if (this.info.ModDate)
      {  return true;         
      }
   
      if (page)
      {   thePage = page;
      }
	
      var myRec = [ 40, 650, 0, 0];              // default position
      if (xpos)
      {   myRec[0] = xpos;
      }
      if (ypos)
      {   myRec[1] = ypos;
      }
	
      var labelText = [ "Mr/Ms", "First_Name", "Surname",
                        "Adress", "City", "Zip_Code", "Country",
                        "Phone", "Mobile_Phone", "E-mail",
                        "Company", "Profession", "Interest_1", "Interest_2",
                        "Hobby" ];   
   
      for ( var i = 0; i < labelText.length; i++)
      {   myRec[2] = myRec[0] + 80;               // length of the label
          myRec[3] = myRec[1] - 15;               // height ( or depth if you like)

          // a label field is created

          var fieldName = labelText[i] + "Label";
          var lf1       = this.addField(fieldName, "text", thePage, myRec);
          lf1.fillColor = color.white;
          lf1.textColor = color.black;
          lf1.readonly  = true;
          lf1.textSize  = 12;
          lf1.value     = labelText[i];
          lf1.display   = display.visible;

          // a text field for the customer to fill-in his/her name is created   
 
          myRec[0] = myRec[2] + 2;               // move 2 pixels to the right 
          myRec[2] = myRec[0] + 140;             // length of the fill-in field

          var tf1         = this.addField(labelText[i], "text", thePage, myRec);
          tf1.fillColor   = color.ltGray;
          tf1.textColor   = color.black;
          tf1.borderStyle = border.s;
          tf1.textSize    = 12;
          tf1.display     = display.visible;
      
          myRec[0] = myRec[0] - 82    // move 82 pixels to the left
          myRec[1] = myRec[1] - 17;   // move 17 pixels down
      } 
         
   }

A little program that uses the script could look like this:

   # ex15_pl

   use PDF::Reuse;

   prDocDir('doc');
   prFile('Ex15.pdf');
   prJs('script1.js');              # To include the JavaScript
   prInit('nameAddress();');        # To call nameAddress(); at start up
   prEnd();

Within the parenthesis of prInit(), you can put JavaScript code to be executed when
the PDF-file is opened. But there is an important limitation you should be aware of.
When the file is opened the JavaScript interpreter I<is working>, but it is B<only 
partially aware of old JavaScripts or interactive fields already defined.> That's
why all functions you refer to within prInit(), should have been included with prJs()
first. The JavaScript interpreter has simply not read the document, when the
initiation is done. 

=head2 Initiate interactive fields

In PDF::Reuse there is one function that assigns values to interactive fields. It is
prField($fieldName, $fieldValue). It works also for old interactive fields in the file.
(I don't know why.) When you use this function, you have to spell the fieldname exactly as it is done in
PDF-file. The spelling is case-sensitive.(And please, avoid initial spaces in names, 
when you define new fields.)


We add values to a few fields in the previous file:

   # ex16_pl

   use PDF::Reuse;

   prDocDir('doc');
   prFile('Ex16.pdf');
   prJs('script1.js');              # To include the JavaScript
   prInit('nameAddress();');
   prField('First_Name', 'Lars');
   prField('Surname', 'Lundberg');
   prField('City', 'Stockholm');
   prField('Country', 'Sweden');       
   prEnd();

=head2 A variant of previous example

You could had written the previous example like this also (if you saved the 
file Ex16.pdf after the fields had been created):

   # ex17_pl

   use PDF::Reuse;
   prDocDir('doc');
   prFile('Ex17.pdf');
   prField('First_Name', 'Lars');
   prField('Surname', 'Lundberg');
   prField('City', 'Stockholm');
   prField('Country', 'Sweden');
   prDocForm('doc/Ex16.pdf');
   prEnd(); 

The prDocForm(), works like prForm() but also takes interactive fields and
JavaScripts with it. If you would have used prForm() here, you would only have received
an empty page. That might be a little confusing, but the graphic elements and the
interactive ones, follow two different logical lines. It can be difficult to see what
is graphic and what is interactive, if you haven't got Acrobat. 

You should put all your PrField, prJs and prInit before the first prDocForm or prDoc,
because all JavaScripts and interactive fields are merged when the program starts
to analyze the first interactive page it is going to include. If you have many calls
to prDoc or prDocForm in your program, only the first one will bring JavaScripts and
interactive functions with it, the rest of the times only graphic elements within
the pages are taken. Perhaps I should try to solve these problems in a future
version of PDF::Reuse.  

=head2 Checking version of the browser 

One problem with JavaScript and Acrobat Reader is that prior to version 5.1 you couldn't
create buttons or text fields dynamically. So we have to be prepared for that. 

I have created a little PDF-file with a text and a button. If the user has an earlier
version of Acrobat Reader or Acrobat, he will be asked to download the latest Acrobat
Reader. If he has a workable version of the browser, the two fields will be hidden.
You should have received 'downLink.pdf' in the distribution.
I also hope that you received 'customerResponse.js'. With those files we can continue
with the next program

    # ex18_pl

    use PDF::Reuse;

    prDocDir('doc');
    prLogDir('run');

    prFile('ex18.pdf');

    prJs('customerResponse.js');
    prInit('nameAddress(0, 100, 700);');
    prInit('butt(0, 400, 700);');
    prField('First_Name', 'Lars');
    prField('Surname', 'Lundberg');
    prField('City', 'Stockholm');
    prDocForm('downLink.pdf');
    prFontSize(18);
    prText(75, 770, 'Please, give us correct information about you !');
    prEnd();

Here the user fills in some data about himself, and if he has Acrobat, he can sign
it electronically and send it back by mail. The form data will be transferred
as an FDF-file, which is fairly compact.
If the user has Acrobat Reader he doesn't get any buttons to sign or return the data by 
mail. He simply has to fill in the form, print it, sign it with a pencil and send the
page by fax. (Adobe now has server programs which can extend the "document rights" so
you can sign and save documents also with the Reader. I haven't tested PDF::Reuse
together with these programs, but if it could be used, the JavaScripts could be changed
and the program would be much more useful.) 

When the program is run, a log is produced. It will be approx. 2% of the formatted 
file.   

=head2 Generate OO-code

You can generate graphic objects and subroutines from B<simple> PDF-files.

(If you want to modify the generated code you need to know a little about the graphic operators
of PDF. Look at "The PDF-reference Manual".)
In the distribution you should have a little program 'graphObj_pl', which I wrote
just for this tutorial. It is far from foolproof, and it could be much more advanced. Anyway
It could anyway be a starting point, and it has produced the graphic objects you will see
here. 

We will write a program that produces weather symbols on a map, and we will use graphic objects,
generated from PDF-files.
The best thing, is probably to run the completed program first. You should have it
in the distribution with the name weatherObj_pl You also need the objects: cloud.pm,
sun.pm, lightn.pm, wind.pm, thermometer.pm, drop.pm, snow.pm. Also there should be
a map of eastern US: EUSA.pdf, and some weather data: weather.dat.

So run the program and look at the result. All the symbols can vary in size, color,
line width, rotation and skew. Of course they can inherit attributes from each other.
All the shapes are vector-based, so you can make them as big as you want and they will
keep there forms. Also you should notice the PDF-file will be fairly small. If you run
the program with weather.dat it will be smaller than 9 kB.

This is the way to make the symbols:
You start by drawing and painting with a program that produces postscript ( or EPS or 
EPSF) or uncompressed PDF-files. I started with the free Pagedraw from http://www.mayura.com
and that's possible. You distill your files with the distiller from Adobe or use the "free"
GhostScript and Gsviewer. A disadvantage with these programs is that you get many
"external references", "name objects", and you have handle them in some way. (You can
do that by having the original PDF-files available. There your modules can find the
appropriate color spaces, fonts, graphic state dictionaries and so on.) But it is
simpler if you start with PDF-files that contain a minimum of "name objects", and
that's why I made most of the symbols here with Mayura Draw. It can export simple PDF-files
straight away. 

When you have distilled or produced your PDF-file, you run the program graphObj_pl
like this:

    perl graphObj_pl myGraphicObject.pdf

and you will (hopefully) get a module 'myGraphicObject.pm'. All the symbols are produced like that.
At the same time as you get the module, you also get a parameter file 'myGraphicObject.dat'.

If you look at the program 'graphObj_pl', you will see that it is not very sophisticated
It only takes the first stream it encounters, and tries to process it. If that is
not what you wanted, it will definitely fail. Then it splits the stream into words
and tries to make standardized lines with the operator at the end. (It 
does not handle long sentences within parenthesis correctly.) It reads the
coordinates of every point to find the minimum values. It tries to analyze the stream
and make it into a module. You get an entry in the objects hash for every unique color, line width and so on.
"External objects" get function calls in the subroutine 'resources'. 

When you use your modules in programs it is B<usually best to avoid external objects.>
If the module needs a font, you can e.g. explicitly give a standard one like 'H' or 'TR'
when you draw the object. That will make your code faster to execute and the PDF-file
smaller. Often you can avoid new graphic state dictionaries by letting the module
use a default one. If you generated a module with 'graphObj_pl',you could write
like this:

   use PDF::Reuse;
   use myGraphicObject;
   use strict;

   prFile('myFile.pdf');

   my $gO = myGraphicObject->new();

   $gO->draw(x => 45,
             y => 100,
             font => 'H',
             defaultGraphState => 1);

   prEnd();

Anyway, if you look in the code of the modules you see that it is a little bit
obscure. Perhaps I should have commented, structured and added better subroutines,
but I haven't had time. It is a starting point.

One interesting case is when the "structure" of a graphic object changes. E.g.
when the mercury of the thermometer goes up and down, depending on the temperature.
To find out what parameters to set you could do like this:

First you draw your object -> transform it to PDF -> generate the module.
Then you make the desired changes to your object -> transform it to PDF with a new
name -> generate a new module and a parameter file.

In the distribution, among the examples, I have put a little experimental program,
which picks out the differences between two parameter files and produces a new one,
with the necessary changes to transform one object to another. E.g.: you make a PDF-file
a thermometer at its lowest point low.pdf, and then one with the highest temperature,
high.pdf, you should be able do the following

    perl graphObj_pl low.pdf                   Produces low.pm and low.dat
    perl graphObj_pl high.pdf                  Produces high.pm and high.dat

    perl paramDiff_pl low.dat high.dat         Produces diff.dat 

If you now run a little program like this:

   use PDF::Reuse;
   use low;
   use strict;

   prFile('myFile.pdf');

   my $l = low->new();

   $l->draw(x => 45,
            y => 700,
                              #  Insert diff.dat here
            font => 'H',
            defaultGraphState => 1);

   prEnd();


If you inserted diff.dat, you would have had "high" drawn. (But more important is
perhaps that you would have seen exactly which parameters to change to vary the
drawing) 


If you modify 'graphObj_pl' a little, you could generate subroutines 
instead of packages. Then you can cut and paste to include the code in
your programs. It is a little more work, but your programs will be faster 
if it is correctly done.

=head2 Simple charts

In the distribution I put a very simple module, 'Histogram.pm'. It is the very 
first program I have done that produces charts, so it can be greatly improved.
It is there to show that is not difficult to design charts. 
Try it, perhaps with this snippet of code (The colors are randomly chosen,so
sometimes they are no good.)

   # ex19_pl

   use PDF::Reuse;
   use Histogram;
   use strict;
  
   prFile('doc/ex19.pdf');
   my $h = Histogram->new();

   $h->values(400, 600, -200, 900, 240, 700, 125, 429, 235, 874);

   ###################################
   # Name to connect to each value
   ###################################

   $h->names('Söderblom', 'Alström', 'Junger', 'Larsson', 'Fält', 
                'Ljung', 'Andersson', 'Persson', 'Qvist', 'Andreen');

   $h->draw(x    => 10,
            y    => 300,
            size => 0.75);
    prEnd();

Also there is another preliminary module in the distribution: to draw line 
charts. Very little time has been spent on it.

   # ex20_pl

   use PDF::Reuse;
   use Linechart;
   use strict;
  
   prFile('doc/ex20.pdf');
   my $l = Linechart->new();

   #####################
   #  Series of values
   #####################

   $l->values(400, 600, 200, 900, 240, 700, 125, 429, 235, 874);
   $l->values(500, 400, 600, 200, 900, 240, 700, 125, 429, 235);
   $l->values(559, 534, 600, 575, 400, 440, 650, 425, 500, 435);
   $l->values(502, 634, 470, 575, 518, 240, 250, 325, 433, 535);
   
   ################################
   # Connect a name to each series 
   ################################

   $l->names('Söderblom', 'Alström', 'Lundberg', 'Frank');

   ######################################
   # What to put along the X-axis
   ######################################

   $l->xNames('Jan', 'Feb', 'Mar', 'Apr', 'May','Jun', 'Jul', 
               'Aug', 'Sep', 'Oct');

   $l->draw(x    => 10,
            y    => 300);
    prEnd();

It is fairly easy to do graphics with the PDF-operators, and the produced files
are very small. Compress them if you want them even smaller.

=head2 Efficient storage of text

Just as an example of how to handle text, I saved "Judges" from King James Bible as 
a text file. I found it at http://www.kingjamesversionofthebible.com/7-judges.html
It received the name 'Judges.txt', and was 110 kB. To transform it to PDF, this
little program can be used:

   #ex21_pl

   use PDF::Reuse;
   use strict;

   my $textFile   = 'Judges.txt';     # The name of the text file
   my $pageTop    = 800;
   my $pageBottom = 40;
   my $x          = 35;               # Left margin
   my $y          = $pageTop;                     
   my $step       = 15;               # Distance between lines (fontsize = 12)

   prDocDir('doc');

   prFile('Judges.pdf');              
   prCompress(1);                     #  Compress streams
   prFont('Times-Roman'); 

   
   open (INFILE, "<$textFile") || 
            die "The text $textFile couldn't be opened, $!\n";

   while (my $line = <INFILE>)
   {   chomp $line;
       prText($x, $y, $line);         # A simple way to handle text                       
       if ($y < $pageBottom)
       {  prPage();
          $y = $pageTop;
       }
       else
       {  $y -= $step;
       }
   }    
   close INFILE;
   prEnd;

When you run this program, the result, 'Judges.pdf' will be 59 kB. It is 33 pages 
of text.

The function prText can be convenient, but if you want more control and perhaps
also more compressed files, you can work directly with the text operators of PDF:

   # ex22_pl

   use PDF::Reuse;
   use strict;

   my $textFile = 'Judges.txt';    
   my $lineNo   = 0;
   my $str;

   prDocDir('doc');

   prFile('JudgesB.pdf');              
   prCompress(1);                   
   my $font = prFont('Times-Roman');       

   open (INFILE, "<$textFile") || 
            die "The text $textFile couldn't be opened, $!\n";

   while (my $line = <INFILE>)
   {   if ($lineNo == 0)
       {  pageTop();
       }

       chomp $line;
       $line =~ s/\(/\\(/;     # To put a backslash before ( 
       $line =~ s/\)/\\)/;     # and ) in the text
       $str .= "($line)'\n";   # Here goes the text with ' as operator
       $lineNo++;

       if ($lineNo > 51)
       {  pageBottom();
       }

   }
   if ($lineNo > 0)
   {   pageBottom();
   }
                       
   close INFILE;
   prEnd;

   sub pageTop
   {   $str .= "BT\n";
       $str .= "/$font 1 Tf\n";
       $str .= "12 0 0 12 35 815 Tm\n"; 
       $str .= "1.25 TL\n";
   } 

   sub pageBottom
   {   $str .= "ET\n";
       prAdd($str);
       prPage();
       undef $str;
       $lineNo = 0;
   }

Remove the line prCompress(1); if you want to see how the streams are formed. 
Notice the lines in the subroutine pageTop.

   $str .= "/$font 1 Tf\n";

Here you can use the internal name for Times-Roman. Later when the page
is going to be written, PDF::Reuse will examine the stream and try to
connect any "name objects",(which always begin with a '/') to a resource.
'1' is the font size.

Next sentence sets the text matrix (and text line matrix)

   $str .= "12 0 0 12 35 815 Tm\n";

The first '12' will multiply along the x-axis, the second '12' multiplies 
along the y-axis. '35' will "move" text objects that many pixels to the right,
and '815' in a similar way upwards.

   $str .= "1.25 TL\n";

'TL' sets the (vertical) distance between lines. In this case it will be
1.25 * 12 = 15 pixels

Every text line which is written to the stream will have this form:

   (string)'

The ' is an operator that moves to the next line and shows the text string.   

When you run this program the PDF-file will be 53 kB.

=head2 Barcodes

This example has not really been tested, so that's why I have put it at the end.
(Anyway it would be fairly easy to make changes if any problems would arise in
"real life".) 
PDF::Reuse can print barcodes, but most often you want more than that. You want
e.g. the numbers in a form humans can read, you want a white background; 
perhaps you want to rotate the pattern, change the size etc. So I have
made a preliminary module for the distribution: Ean13.pm. You need
GD::Barcode::EAN13 to run it.

   # ex23_pl

   use PDF::Reuse;
   use Ean13;
   use strict;

   prFile('doc/ex23.pdf');

   prMbox(0, 0, 690, 735);
   prForm( { file   => 'EUSA.pdf',
             adjust => 1 } );

   my $e = Ean13->new();

   $e->draw(x          => 70,
            y          => 530,
            value      => '1234567890123',
            background => '1 1 1',
            size       => 1.5);

   prEnd();

You can also have rotate, xSize and ySize, if you want more parameters for draw.  


=head1 AUTHOR

Lars Lundberg elkelund@worldonline.se

=head1 COPYRIGHT

Copyright (C) 2003 Lars Lundberg, Solidez HB. All rights reserved.
This documentation is free; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 DISCLAIMER

You get this tutorial free as it is, but NOTHING IS GUARANTEED to work, whatever 
implicitly or explicitly stated in this document, and everything you do, 
you do AT YOUR OWN RISK - I will not take responsibility 
for any damage, loss of money and/or health that may arise from the use of this document!
 
 
   
 

  

   
 

   
  









    
 
 
   

  
 
