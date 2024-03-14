Mock landing page for CIS 350 Project that autodeploys on pushes to main

Checks out the repository code and fetches the Hugo theme submodules.
Sets up the Hugo environment by installing the specified version.
Compiles the Hugo static files, including drafts, enabling garbage collection, and minifying the output.
Publishes the compiled static files to the gh-pages branch, which is used by GitHub Pages to serve the website, aw.
