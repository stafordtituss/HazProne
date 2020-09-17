<?php                                                                                                                                                                                                                                           
if(isset($_POST['submit'])) {                                                                                               
    $target = $_REQUEST['ip-address'];                                                                                      
    $cmd="ping -n 3 $target";                                                                                               
    $result="The results of your scan are:";                                                                            
    }                                                                                                                                                                                                                                               
    ?>                                                                                                                      
<html>                                                                                                                  
<body>                                                                                                                  
<?php                                                                                                                   
    echo $result;                                                                                                           
    echo '<pre>';                                                                                                           
    passthru($cmd);                                                                                                         
    echo '</pre>';                                                                                                           
?>                                                                                                                     
</body>                                                                                                                 
</html>