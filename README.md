# OMRS - Optical Materials Research System

OMRS is a Java JSP/Servlet web application for managing optical materials research work. It supports student experiment submission, supervisor review, repository browsing, learning materials, quizzes, notifications, profile management, and AI-assisted help.

## Tech Stack

- Java 8
- JSP and Servlets
- Apache Tomcat
- MySQL
- NetBeans Ant project
- JDBC with MySQL Connector/J
- JSTL tag libraries

## Project Structure

```text
OMRS-NetBeans/
+-- src/java/com/omrs/        # Java source code
|   +-- config/               # Database connection
|   +-- dao/                  # Data access classes
|   +-- filter/               # Servlet filters
|   +-- model/                # Model classes
|   +-- servlet/              # Servlet controllers
+-- web/                      # JSP pages and web resources
|   +-- WEB-INF/              # web.xml and libraries
|   +-- pages/                # Application pages
+-- nbproject/                # NetBeans project configuration
+-- database.sql              # Main database setup script
+-- dist/                     # Generated WAR files
+-- build.xml                 # Ant build file
```

## Requirements

Install the following before running the project:

- JDK 8 or newer
- Apache NetBeans IDE
- Apache Tomcat 8 or 9
- MySQL Server
- phpMyAdmin or MySQL command line client

The project includes required JAR files under `web/WEB-INF/lib`.

## Database Setup

1. Start MySQL.
2. Open phpMyAdmin or a MySQL client.
3. Import `database.sql`.

Using MySQL command line:

```bash
mysql -u root -p < database.sql
```

The default database name is:

```text
omrs_db
```

The current local database connection is configured in:

```text
src/java/com/omrs/config/DBConnection.java
```

Default connection values:

```text
URL:  jdbc:mysql://localhost:3306/omrs_db
User: root
Pass: empty password
```

Update these values if your MySQL username, password, host, or database name is different.

## Local Setup in NetBeans

1. Clone the repository:

```bash
git clone https://github.com/your-username/your-repository-name.git
cd your-repository-name
```

2. Open NetBeans.
3. Select `File > Open Project`.
4. Choose the `OMRS-NetBeans` project folder.
5. Configure Apache Tomcat in NetBeans if it is not already registered.
6. Import `database.sql` into MySQL.
7. Confirm the database settings in `DBConnection.java`.
8. Right-click the project and select `Clean and Build`.
9. Right-click the project and select `Run`.

The application should open at a local Tomcat URL similar to:

```text
http://localhost:8080/OMRS/
```

## Build WAR File

From NetBeans:

1. Right-click the project.
2. Select `Clean and Build`.
3. The generated WAR file will be created in:

```text
dist/OMRS.war
```

From terminal, if Apache Ant is installed:

```bash
ant clean dist
```

## Deploy to Tomcat

1. Build the WAR file.
2. Copy `dist/OMRS.war` to the Tomcat `webapps` directory.
3. Start or restart Tomcat.
4. Visit:

```text
http://localhost:8080/OMRS/
```

You can also deploy through the Tomcat Manager page if it is enabled.

## Server Deployment Checklist

For deployment on a VPS, hosting server, or university server:

1. Install Java, Tomcat, and MySQL.
2. Create/import the database using `database.sql`.
3. Update database credentials in `DBConnection.java`.
4. Build the WAR file.
5. Deploy the WAR file to Tomcat.
6. Configure upload storage using `OMRS_UPLOAD_DIR`.
7. Restart Tomcat.
8. Test login, signup, file upload, repository browsing, learning materials, and supervisor review.

## Upload Directory

The project uses an upload directory for experiment files and downloads. It can be configured with:

- `OMRS_UPLOAD_DIR` environment variable
- `omrs.upload.dir` Java system property
- `OMRS_UPLOAD_DIR` context parameter in `web/WEB-INF/web.xml`

Example Linux deployment path:

```text
/home/your-user/omrs-files
```

Make sure Tomcat has permission to read and write to this folder.

## AI Assistant Configuration

The AI assistant servlet reads the Gemini API key from:

- `GEMINI_API_KEY` environment variable
- `gemini.api.key` Java system property
- `GEMINI_API_KEY` context parameter in `web/WEB-INF/web.xml`

For GitHub and production deployment, do not commit real API keys. Use an environment variable or server-side configuration instead.

Example:

```bash
export GEMINI_API_KEY="your-api-key"
```

## GitHub Publishing Notes

Before pushing this project to GitHub:

1. Remove real API keys and passwords from source files.
2. Avoid committing private NetBeans files from `nbproject/private/`.
3. Avoid committing generated files from `build/` unless your submission requires them.
4. Keep the source code, `web/`, `nbproject/`, `build.xml`, and database script.
5. Add screenshots or demo credentials only if they are safe to share.

GitHub Pages cannot host this project because it is a Java Servlet application. Deploy it to Tomcat or another Java web application server.

## Suggested `.gitignore`

```gitignore
build/
dist/
nbproject/private/
*.class
*.war
```

If your final-year project submission requires the WAR file, upload it separately as a GitHub Release or include it only if your supervisor requests it.

## Main Features

- User signup and login
- Student, supervisor, and researcher roles
- Supervisor approval workflow
- Student experiment records
- Optical calculation tools
- Experiment file upload and download
- Supervisor experiment review
- Repository browsing and search
- Learning materials and quizzes
- Notifications
- User profile management
- AI assistant integration

## Common Issues

### Database Connection Failed

Check that MySQL is running and that the values in `DBConnection.java` match your local database setup.

### Driver Not Found

Confirm that the MySQL Connector/J JAR exists in `web/WEB-INF/lib`.

### 404 After Deployment

Confirm the deployed WAR name. If the file is deployed as `OMRS.war`, the app URL is usually:

```text
http://localhost:8080/OMRS/
```

### File Upload Does Not Work

Check that the upload directory exists and that Tomcat has write permission.

## License

This project is for academic use. Add a license file if you plan to publish or reuse it publicly.
