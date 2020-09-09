<?php
if ($conn->connect_errno) {
    echo "Failed to connect to MySQL: (" . $conn->connect_errno . ") " . $conn->connect_error;
}
echo $conn->host_info . "\n";

$sql = "SELECT QuesID, question, answer FROM ques_table";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
  // output data of each row
  while($row = $result->fetch_assoc()) {
    echo "id: " . $row["QuesID"]. " - Question: " . $row["question"]. " - Answer: " . $row["answer"]. "<br>";
  }
} else {
  echo "0 results";
}
?>