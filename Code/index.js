// this is azure function code move the file form landing folder to staging or rejected folder
module.exports = async function (context, myBlob) {
  context.log("JavaScript blob trigger function processed blob  n Blob: ");

  context.log("Azure function started");

  var result = true;
  try {
    const cleanJsonString = myBlob.toString().replace(/\s/g, "");
    JSON.parse(cleanJsonString);
  } catch (exception) {
    context.log(exception);
    result = false;
  }
  if (result) {
    context.bindings.stagingFolder = myBlob.toString();
    context.log("File copied to staging folder");
  } else {
    context.bindings.rejectedFolder = myBlob.toString();
    context.log("File copied to rejected folder");
  }

  context.log("*Azure Function Ended Successfully* ");
};
