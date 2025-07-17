defmodule FullStacli do
  def main(args) do
    validate_deps()
    {folder, controller} = parse_args(args)

    IO.puts("🚀 Bootstrapping fullstack project into: #{folder}")
    create_directories(folder)

    [
      Task.async(fn -> setup_frontend(folder, controller) end),
      Task.async(fn -> setup_backend(folder, controller) end)
    ]
    |> Enum.map(&Task.await(&1, 60_000 * 10))

    IO.puts("✅ Project '#{folder}' bootstrapped successfully!")
  end

  defp validate_deps() do
    IO.puts("🔎 Checking for dependencies...")

    ["node -v", "npm -v", "ng version", "nest --version"]
    |> Enum.each(fn cmd ->
      {output, exit_code} = System.cmd("bash", ["-c", cmd], stderr_to_stdout: true)

      if exit_code != 0 do
        IO.puts("❌ Dependency check failed: `#{cmd}`")
        IO.puts(output)
        System.halt(1)
      else
        IO.puts("✅ #{cmd} found")
      end
    end)
  end

  defp parse_args([folder_name, controller_name]) do
    {folder_name, normalize_controller(controller_name)}
  end

  defp parse_args([folder_name]) do
    IO.puts("ℹ️ No controller name provided. Using default: `Hello`")
    {folder_name, "hello"}
  end

  defp parse_args([]) do
    IO.puts("""
    ❌ Usage: ./fullstack_bootstrap <project-folder> [ControllerName]

    Example:
      ./fullstack_bootstrap my-app Users
    """)
    System.halt(1)
  end

  defp normalize_controller(name) do
    name
    |> Macro.underscore()
    |> String.trim()
    |> String.replace(~r/[^a-z0-9_]/i, "")
  end

  defp create_directories(folder) do
    File.mkdir_p!("#{folder}/frontend")
    File.mkdir_p!("#{folder}/backend")
  end

defp run_shell(cmd, label) do
  {output, exit_code} = System.cmd("bash", ["-c", cmd |> String.trim()], stderr_to_stdout: true)

  IO.puts("[#{label}] " <> output)

  if exit_code != 0 do
    IO.puts("❌ [#{label}] setup failed.")
    System.halt(exit_code)
  end
end

defp setup_backend(folder, controller) do
  IO.puts("🔧 [backend] Setting up NestJS + Prisma (SQLite)...")

  cmd = """
  cd #{folder} &&
  npm i -g @nestjs/cli &&
  npm init nest backend -- --skip-git &&
  cd backend &&
  npm install prisma --save-dev &&
  npm install @prisma/client cors &&
  npx prisma init --datasource-provider sqlite
  """

  run_shell(cmd, "backend")
  write_backend_files(folder, controller)
end

defp setup_frontend(folder, controller) do
  IO.puts("📦 [frontend] Installing Angular 19 + Tailwind + PrimeNG...")

  cmd = """
  cd #{folder} &&
  ng new frontend --minimal --skip-git --standalone --skip-tests --inline-template false --inline-style --defaults --routing=false &&
  cd frontend &&
  npm install -D tailwindcss postcss autoprefixer --force &&
  npm install primeng@19 @primeng/themes@19 primeicons --force
  """

  run_shell(cmd, "frontend")
  write_frontend_files(folder, controller)
end

defp write_backend_files(folder, controller) do
  controller_cap = String.capitalize(controller)

  File.write!("#{folder}/backend/src/main.ts", """
  import { NestFactory } from "@nestjs/core";
  import type { NestExpressApplication } from "@nestjs/platform-express";
  import { AppModule } from "./app.module";
  import * as cors from "cors";

  async function bootstrap() {
    const app = await NestFactory.create<NestExpressApplication>(AppModule);
    app.use(cors());
    await app.listen(process.env.PORT || 3000);
  }
  bootstrap();
  """)

  File.write!("#{folder}/backend/src/prisma.service.ts", """
  import { Injectable, OnModuleInit } from "@nestjs/common";
  import { PrismaClient } from "@prisma/client";

  @Injectable()
  export class PrismaService extends PrismaClient implements OnModuleInit {
    onModuleInit() {
      this.$connect();
    }
  }
  """)

  File.mkdir_p!("#{folder}/backend/src/#{controller}")
  File.write!("#{folder}/backend/src/#{controller}/#{controller}.service.ts", """
  import { Injectable } from "@nestjs/common";
  import { PrismaService } from "src/prisma.service";

  @Injectable()
  export class #{controller_cap}Service {
    constructor(private readonly prisma: PrismaService) {}
  }
  """)

  File.write!("#{folder}/backend/src/#{controller}/#{controller}.controller.ts", """
  import { Body, Controller, Delete, Get, Headers, Param, Patch, Post, Put } from "@nestjs/common";
  import { #{controller_cap}Service } from "./#{controller}.service";

  @Controller("#{controller}")
  export class #{controller_cap}Controller {
    constructor(private readonly service: #{controller_cap}Service) {}
  }
  """)

  File.write!("#{folder}/backend/src/app.module.ts", """
  import { Module } from "@nestjs/common";
  import { #{controller_cap}Controller } from "./#{controller}.controller";
  import { #{controller_cap}Service } from "./#{controller}.service";
  import { PrismaService } from "./prisma.service";

  @Module({
    controllers: [#{controller_cap}Controller],
    providers: [#{controller_cap}Service, PrismaService],
  })
  export class AppModule {}
  """)
end

defp write_frontend_files(folder, controller) do
  controller_cap = controller |> String.capitalize()
  File.write!("#{folder}/frontend/.postcssrc.json", """
  {
    "plugins": {
      "@tailwindcss/postcss": {}
    }
  }
  """)

  File.write!("#{folder}/frontend/src/styles.css", "@import 'tailwindcss';")
  File.write!("#{folder}/frontend/src/app/app.component.html", """
  <div class="min-h-svh px-4 py-2">
    <div class="mb-4 flex justify-between">
      <h2 class="text-3xl tracking-wide">#{controller_cap}</h2>
    </div>

    <div class="p-2">Major content here!!!</div>
  <div>
  """)
  File.write!("#{folder}/frontend/src/app/app.component.ts", """
  import { FormBuilder, FormGroup, FormsModule, ReactiveFormsModule, Validators} from '@angular/forms';
  import { CommonModule } from '@angular/common';
  import { Component, OnInit } from '@angular/core';
  import { firstValueFrom } from 'rxjs';

  import { InputTextModule } from 'primeng/inputtext';
  import { ButtonModule } from 'primeng/button';
  import { HttpClient } from '@angular/common/http';

  @Component({
    templateUrl: './app.component.html',
    selector: 'app-root',
    standalone: true,
    styles: [],
    imports: [
      ReactiveFormsModule, FormsModule, CommonModule,
      ButtonModule, InputTextModule,
    ],
  })
  export class AppComponent implements OnInit {
    api = "http://localhost:3000/#{controller}"
    selectedId: string | null = null;
    form!: FormGroup
    adding = false
    data: {id: string}[] = []

    constructor(
      private http: HttpClient,
      private fb: FormBuilder
    ) {}

    ngOnInit() {
      this.createForm();
    }

    private createForm() {
      this.form = this.fb.group({
        name: []
      })
    }

    private getDataAndIndex(id: string) {
      const index = this.data.findIndex((x) => x.id === id);

      if (index == -1) {
        return { index, data: null };
      }

      return {
        index,
        data: this.data[index],
      };
    }

    select(id: string) {
      const {data} = this.getDataAndIndex(id);

      if (!data) {
        return;
      }

      this.selectedId = id;
      this.form.patchValue(data);
    }

    newOne() {
      this.adding = true;
    }

    cancel() {
      this.form.reset();
      this.adding = false;
      this.selectedId = null;
    }

    getData() {
      return firstValueFrom(this.http.get(this.api))
    }

    delete(id: string) {
      return firstValueFrom(this.http.delete(`${this.api}/${id}`))
    }

    update(data: any) {
      return firstValueFrom(this.http.put(this.api, data))
    }

    create(data: any) {
      return firstValueFrom(this.http.post(this.api, data))
    }
  }

  """)

  File.write!("#{folder}/frontend/src/app/app.config.ts", """
  import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
  import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
  import { providePrimeNG } from 'primeng/config';
  import Aura from '@primeng/themes/aura';
  import { provideHttpClient } from '@angular/common/http';

  export const appConfig: ApplicationConfig = {
    providers: [
      provideZoneChangeDetection({ eventCoalescing: true }),
      provideAnimationsAsync(),
      provideHttpClient(),
      providePrimeNG({
        theme: {
          preset: Aura,
        },
      }),
    ],
  };
  """)
end

end
