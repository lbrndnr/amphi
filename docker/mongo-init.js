db.createUser(
    {
        user: "amphi",
        pwd: "amphi",
        roles: [
            {
                role: "admin",
                db: "amphi"
            }
        ]
    }
);