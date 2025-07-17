# FullStaCLI

A CLI tool to bootstrap full-stack applications.

This tool generates a minimal project structure for a modern web application, including a backend with NestJS and a frontend with Angular.

## Todo

- Add option to different frameworks
- Deep options for each framework
- Distribute an .exe instead of shell to avoid the need for the Erlang VM.

## Features

- **Backend:**
  - NestJS
  - Prisma with SQLite
- **Frontend:**
  - Angular 19
  - Tailwind CSS
  - PrimeNG

## Easy usage for Elixir community

Just download the [FullStacli](/fullstacli) shell script, and [use it!](#usage)

### Disclaimer 🚫

It'll only works if Erlang VM is installed on your machine!

## Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/nsx07/fullstacli
    cd fullstacli
    ```

2.  **Install dependencies:**

    This tool requires npm, Angular CLI, NestJS CLI and Elixir to be installed on your system.

3.  **Compile the application:**
    ```bash
    mix escript.build
    ```

## Usage

To create a new full-stack project, run the following command:

```bash
./fullstacli <project-folder> [ControllerName]
```

- `<project-folder>`: The name of the directory where the project will be created.
- `[ControllerName]` (optional): The name of the main controller for your application. If not provided, it defaults to `Hello`.

### Example

```bash
./fullstacli my-awesome-app Users
```

### Purpose

I created this tool to optimize productivity in tests with short execution times, so you can focus more on business logic rather than the tool itself.

This will create a new directory named `my-awesome-app` with a NestJS backend and an Angular frontend, including a `UsersController` and related files.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
