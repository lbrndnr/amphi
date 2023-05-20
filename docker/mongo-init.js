print("Setup amphi dbs");

db = db.getSiblingDB("amphi");
db.createUser(
  {
    user: "amphi",
    pwd: "amphi",
    roles: [
      {role: "dbAdmin", db: "amphi"}, 
      {role: "readWrite", db: "amphi"}
    ],
  },
);