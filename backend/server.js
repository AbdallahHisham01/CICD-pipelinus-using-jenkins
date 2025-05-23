const express = require("express");
const cors = require('cors');
const mongoose = require("mongoose");
const port = 3001;
const routes = require("./routes");

main().catch((err) => console.log(err));

async function main() {
  const mongodbHost = process.env.MONGODB || 'localhost'; // Default to localhost if not set
  const mongoPort = process.env.MONGO_PORT || '27017'; // Default to 27017 if not set

  // Use the environment variables or fallback to localhost and default port
  await mongoose.connect(`mongodb://${mongodbHost}:${mongoPort}/todos`, {
    useUnifiedTopology: true,
    useNewUrlParser: true,
  });

  const app = express();
  app.use(cors());
  app.use(express.json());
  app.use("/api", routes);

  app.listen(port, () => {
    console.log(`Server is listening on port: ${port}`);
  });
}

