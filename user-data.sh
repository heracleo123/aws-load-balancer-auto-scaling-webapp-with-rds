#!/bin/bash
# Update system
yum update -y

# Install Apache web server
yum install -y httpd

# Install PHP and required extensions
yum install -y php php-mysqlnd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create index.php file
cat > /var/www/html/index.php << 'EOFPHP'
<?php
// Database connection details
$servername = "${db_endpoint}";
$username = "${db_username}";
$password = "${db_password}";
$dbname = "${db_name}";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Handle form submission
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = $_POST['name'] ?? '';
    $email = $_POST['email'] ?? '';
    
    if (!empty($name) && !empty($email)) {
        $stmt = $conn->prepare("INSERT INTO ${table_name} (name, email) VALUES (?, ?)");
        $stmt->bind_param("ss", $name, $email);
        
        if ($stmt->execute()) {
            // Redirect after successful insert to prevent form resubmission
            header("Location: " . $_SERVER['PHP_SELF'] . "?success=1");
            exit();
        } else {
            $error = "Error: " . $stmt->error;
        }
        $stmt->close();
    } else {
        $error = "Please fill in both fields.";
    }
}

// Display success or error message from redirect
$message = '';
if (isset($_GET['success'])) {
    $message = "<p style='color: green; padding: 10px; background: #d4edda; border-radius: 5px;'>✅ Data inserted successfully!</p>";
} elseif (isset($error)) {
    $message = "<p style='color: red; padding: 10px; background: #f8d7da; border-radius: 5px;'>❌ " . htmlspecialchars($error) . "</p>";
}

// Get EC2 Instance ID
$instance_id = @file_get_contents("http://169.254.169.254/latest/meta-data/instance-id");
if ($instance_id === false) {
    $instance_id = "Unable to fetch";
}

// Get Availability Zone
$availability_zone = @file_get_contents("http://169.254.169.254/latest/meta-data/placement/availability-zone");
if ($availability_zone === false) {
    $availability_zone = "Unable to fetch";
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EC2 + RDS Data Entry</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f0f0f0;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
        }
        .info {
            background-color: #e7f3ff;
            padding: 10px;
            border-left: 4px solid #007bff;
            margin: 20px 0;
        }
        label {
            display: block;
            margin-top: 15px;
            font-weight: bold;
        }
        input[type="text"], input[type="email"] {
            width: 100%;
            padding: 8px;
            margin-top: 5px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        input[type="submit"] {
            background-color: #007bff;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-top: 20px;
            font-size: 16px;
        }
        input[type="submit"]:hover {
            background-color: #0056b3;
        }
        .data-table {
            margin-top: 30px;
            width: 100%;
            border-collapse: collapse;
        }
        .data-table th, .data-table td {
            border: 1px solid #ddd;
            padding: 10px;
            text-align: left;
        }
        .data-table th {
            background-color: #007bff;
            color: white;
        }
        .data-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Cloud Final Project - Web Application</h1>
        
        <div class="info">
            <strong>EC2 Instance ID:</strong> <?php echo htmlspecialchars($instance_id); ?><br>
            <strong>Availability Zone:</strong> <?php echo htmlspecialchars($availability_zone); ?>
        </div>
        
        <?php echo $message; ?>
        
        <h2>Add New User</h2>
        <form method="post" action="">
            <label for="name">Name:</label>
            <input type="text" id="name" name="name" required>
            
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required>
            
            <input type="submit" value="Submit">
        </form>
        
        <h2>Recent Entries</h2>
        <table class="data-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Created At</th>
                </tr>
            </thead>
            <tbody>
                <?php
                $result = $conn->query("SELECT * FROM ${table_name} ORDER BY id DESC LIMIT 10");
                if ($result && $result->num_rows > 0) {
                    while($row = $result->fetch_assoc()) {
                        echo "<tr>";
                        echo "<td>" . htmlspecialchars($row['id']) . "</td>";
                        echo "<td>" . htmlspecialchars($row['name']) . "</td>";
                        echo "<td>" . htmlspecialchars($row['email']) . "</td>";
                        echo "<td>" . htmlspecialchars($row['created_at']) . "</td>";
                        echo "</tr>";
                    }
                } else {
                    echo "<tr><td colspan='4'>No data available</td></tr>";
                }
                ?>
            </tbody>
        </table>
    </div>
</body>
</html>
<?php
$conn->close();
?>
EOFPHP

# Set proper permissions
chown apache:apache /var/www/html/index.php
chmod 644 /var/www/html/index.php

# Restart Apache to apply changes
systemctl restart httpd
