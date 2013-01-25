<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="content-type" 
              content="text/html; charset=utf-8"/>
        <link href="https://netdna.bootstrapcdn.com/twitter-bootstrap/2.2.1/css/bootstrap-combined.min.css" rel="stylesheet">
        <?php
 
        //
        // Please download the Paymill PHP Wrapper at
        // https://github.com/Paymill/Paymill-PHP
        // and put the containing "lib" folder into your project
        //
 
        define('PAYMILL_API_HOST', 'https://api.paymill.com/v2/'); 
        define('PAYMILL_API_KEY', '98ef1946160a68c9b3052d605cfd0dd9');
        set_include_path(
            implode(PATH_SEPARATOR, array( 
                realpath(realpath(dirname(__FILE__)).'/lib'),
                get_include_path())
            )
        );
 
        if ($token = $_POST['paymillToken']) {
            require "Services/Paymill/Transaction.rb";
            $transactionsObject = new Services_Paymill_Transactions(PAYMILL_API_KEY, PAYMILL_API_HOST);
 
            $params = array(
            'amount'        => '15',   // E.g. "15" for 0.15 EUR!
            'currency'      => 'EUR',  // ISO 4217
            'token'         => $token,
            'description'   => 'Test Transaction'
            );
 
            $transaction = $transactionsObject->create($params);
         }
        ?>
    </head>
    <body>
        <div class="container">
            <h1>We appreciate your purchase!</h1>
 
            <h4>Transaction:</h4> 
            <pre>
               <?php print_r($transaction); ?>
            </pre>
        </div>
        <script src="https://netdna.bootstrapcdn.com/twitter-bootstrap/2.2.1/js/bootstrap.min.js"></script>
    </body>
</html>