<head>
  <link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
  <link rel="stylesheet" href="/resources/demos/style.css">
  <script src="https://code.jquery.com/jquery-1.12.4.js"></script>
  <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
  <script>
  $( function() {
    $( "#accordion" ).accordion();
  } );
  </script>

</head><?php

include "db_connect.php";

error_reporting(E_ALL);
ini_set('display_errors', 1);

$keyword = $_GET['keyword'];
//echo $keyword;

echo "<h1>Search Results for Keyword :" . $keyword . "</h1>";

$sql = "SELECT QuesID, question, answer FROM ques_table WHERE question LIKE '%$keyword%'";

//echo "SQL Statement = ". $sql . "<br>";

$result = $conn->query($sql) or die (mysqli_error($conn));

if ($result && $result->num_rows) {
	echo "<div id='accordion'>";
	while($row = $result->fetch_assoc()) {
   // echo "id: " . $row["QuesID"]. " - Question: " . $row["question"]. " - Answer: " . $row["answer"]. "<br>";
	echo "<h3>".$row["question"]."</h3>";
	echo "<div><p>".$row["answer"]."</p></div>";

	}
	echo "</div>";
} else {
	echo "0 results";
}
?>
