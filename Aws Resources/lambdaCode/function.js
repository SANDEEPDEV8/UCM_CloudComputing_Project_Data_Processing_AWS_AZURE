const aws = require("aws-sdk");

const s3 = new aws.S3({ apiVersion: "2006-03-01" });

exports.handler = async (event, context) => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  try {
    // Get raw file content from event body
    const fileContent = event.body;

    // Generate current date to create folder structure
    const currentDate = new Date();
    const year = currentDate.getFullYear();
    const month = String(currentDate.getMonth() + 1).padStart(2, "0");
    const day = String(currentDate.getDate()).padStart(2, "0");
    const folderPath = `${year}/${month}/${day}/`;

    // Generate unique key for the uploaded file
    // const fileName = `vehicleData_${year}_${month}_${day}.json`; // Modify with your desired file name
    const fileName = `Customer_Valid.json`;
    const key = folderPath + fileName;
    console.log("Generated key:", key);

    const params = {
      Bucket: "iotvehicledata5566",
      Key: key,
      Body: fileContent,
    };

    console.log("Uploading file to S3...");
    await s3.upload(params).promise();
    console.log("File uploaded successfully.");

    const message = `File uploaded successfully to: ${params.Bucket}/${params.Key}`;
    console.log(message);

    return {
      statusCode: 200,
      body: JSON.stringify({ message }),
    };
  } catch (err) {
    console.error("Error:", err.message);
    const errorMessage = err.message || "Unknown error";
    const errorResponse = {
      statusCode: err.statusCode || 500,
      body: JSON.stringify({ error: errorMessage }),
    };
    console.log("Error response:", JSON.stringify(errorResponse));
    return errorResponse;
  }
};
