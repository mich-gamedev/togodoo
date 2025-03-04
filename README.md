![header](https://github.com/mich-gamedev/togodoo/blob/master/assets/header.png)

# Togodoo

A tree-based note taking and to-do app, inspired by HTML and Godot's scene tree

> [!WARNING]
> This project doesn't currently have any stable releases, and is WIP


# How to test

Currently there isnt any stable releases, so you should clone the repository locally to test.

## Prerequesites
Godot v4.3.stable

## Editor settings

It's reccomended you set `docks/filesystem/textfile_extensions` to include `*.togodoo` in the list, otherwise you wont see project files within the editor.

## Skipping project manager, and debugging in-editor

go to Debug > Customize Run Instances, and add `--project=path_to_your_project.togodoo` to load a project directly and allow for using the debugger in that project.
![image](https://github.com/user-attachments/assets/3b39ef18-4be9-4592-8302-c268c37f24a5)
