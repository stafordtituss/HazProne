<!DOCTYPE html>
<html>
  <head>
    <!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">

<!-- jQuery library -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>

<!-- Latest compiled JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
  </head>

  <form class="form-horizontal" action="ping.php" method="post">
    <fieldset>
    
    <!-- Form Name -->
    <legend>WARNING :: BROKEN PING!!</legend>
    
    <!-- Text input-->
    <div class="form-group">
      <label class="col-md-4 control-label" for="textinput">IP-address</label>  
      <div class="col-md-5">
      <input id="ip-address" name="ip-address" type="text" placeholder="ip-address" class="form-control input-md" required="">
      <span class="help-block">Enter your IP Address</span>  
      </div>
    </div>
    
    <!-- Button -->
    <div class="form-group">
      <label class="col-md-4 control-label" for="submit"></label>
      <div class="col-md-4">
        <button id="submit" name="submit" class="btn btn-primary">PING IT</button>
      </div>
    </div>
    
    </fieldset>
    </form>

</html>
