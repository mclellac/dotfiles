return {
  s("tf", {
    t({
      "terraform {",
      "  required_providers {",
      "    ",
    }),
    i(1, "aws"),
    t({ " = {", '      source  = "' }),
    i(2, "hashicorp/aws"),
    t({ '"', '      version = "~> ' }),
    i(3, "5.0"),
    t({ '"', "    }", "  }", "}" }),
  }),
  s("provider", {
    t({
      'provider "',
    }),
    i(1, "aws"),
    t({ '" {', '  region = "' }),
    i(2, "us-east-1"),
    t({ '"', "}" }),
  }),
  s("resource", {
    t({
      'resource "',
    }),
    i(1, "aws_instance"),
    t({ '" "' }),
    i(2, "example"),
    t({ '" {', "  " }),
    i(3, 'ami = "ami-12345"'),
    t({ "", "}" }),
  }),
  s("data", {
    t({
      'data "',
    }),
    i(1, "aws_ami"),
    t({ '" "' }),
    i(2, "example"),
    t({ '" {', "  " }),
    i(3, "most_recent = true"),
    t({ "", "}" }),
  }),
  s("variable", {
    t({
      'variable "',
    }),
    i(1, "name"),
    t({ '" {', '  description = "' }),
    i(2, "Description"),
    t({ '"', "  type        = " }),
    i(3, "string"),
    t({ "", '  default     = "' }),
    i(4, "value"),
    t({ '"', "}" }),
  }),
  s("output", {
    t({
      'output "',
    }),
    i(1, "name"),
    t({ '" {', "  value = " }),
    i(2, "aws_instance.example.id"),
    t({ "", "}" }),
  }),
  s("module", {
    t({
      'module "',
    }),
    i(1, "name"),
    t({ '" {', '  source = "' }),
    i(2, "./module-path"),
    t({ '"', "  " }),
    i(3, 'var = "value"'),
    t({ "", "}" }),
  }),
  s("locals", {
    t({
      "locals {",
      "  ",
    }),
    i(1, "name"),
    t({ ' = "' }),
    i(2, "value"),
    t({ '"', "}" }),
  }),
  s("lifecycle", {
    t({
      "lifecycle {",
      "  ",
    }),
    i(1, "create_before_destroy = true"),
    t({ "", "}" }),
  }),
  s("provisioner", {
    t({
      'provisioner "',
    }),
    i(1, "local-exec"),
    t({ '" {', '  command = "' }),
    i(2, "echo 'Hello World'"),
    t({ '"', "}" }),
  }),
  s("backend", {
    t({
      "terraform {",
      '  backend "',
    }),
    i(1, "s3"),
    t({ '" {', '    bucket = "' }),
    i(2, "mybucket"),
    t({ '"', '    key    = "' }),
    i(3, "path/to/my/key"),
    t({ '"', '    region = "' }),
    i(4, "us-east-1"),
    t({ '"', "  }", "}" }),
  }),
}
