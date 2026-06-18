
# Uploading & Syncing

## Logging into Server

	folio3

or

	ssh cblackwell@10.101.110.240

rsync -avz --progress --exclude='sync-site.sh' /Users/cblackwell/Dropbox/Courses/~Spring\ 2026/50_Objects/50-Objects-Lectures/lectures/50-Objects-Lectures cblackwell@folio3.furman.edu:~/lectures/

## Change URLs for Server

Confirm what will be changed:
	
	grep -rlI 'http://localhost:8080' .

Replace the address of the LSJ app:

	grep -rlI 'http://localhost:8080' . | xargs -I {} sed -i '.bak' 's|http://localhost:8080|https://folio3.furman.edu/lsj/|g' {}

Confirm that you got them all:

	grep -rlI --exclude='*.bak' 'http://localhost:8080' .

Delete the `.bak` files:

	find . -name '*.bak' -delete

## Change the URLs for Local Work

Confirm what will be changed:
	
	grep -rlI 'https://folio3.furman.edu/lsj/' .

Replace the address of the LSJ app:

	grep -rlI '	grep -rlI 'https://folio3.furman.edu/lsj/' .
' . | tee xargs -I {} sed -i '.bak' 's|https://folio3.furman.edu/lsj/|http://localhost:8080|g' {}

Confirm that you got them all:

	grep -rlI --exclude='*.bak' 'https://folio3.furman.edu/lsj/' .

Delete the `.bak` files:

	find . -name '*.bak' -delete

## Upload Dramaturg Files

Sync to server:

	rsync -avz --progres --exclude='ai_queries' --exclude='.git' --exclude='.gitignore' --exclude='.DS_Store' /Users/cblackwell/cite/grok/Dramaturg/editions/html/ cblackwell@folio3.furman.edu:~/dramaturg/

On the server:

sudo rsync -avz --progress --exclude='attic' --exclude='julia'  --exclude='.git' --exclude='.gitignore' --exclude='.DS_Store' /home/cblackwell/dramaturg/ /var/www/html/dramaturg

## Sync Website Index

sudo cp /Users/cblackwell/website/index.html /var/www/html/

## Sync MorphMaker

Sync to server:

	rsync -avz --progres --exclude='ai_queries' --exclude='.git' --exclude='.gitignore' --exclude='.DS_Store' /Users/cblackwell/cite/grok/MorphologyDocumenter/ cblackwell@folio3.furman.edu:/home/cblackwell/morph/

On the server:

	sudo rsync -avz --progress --exclude='attic' --exclude='julia'  --exclude='.git' --exclude='.gitignore' --exclude='.DS_Store' /home/cblackwell/morph /var/www/html/

## Sync LSJ

Sync to server:

	rsync -avz --progress --exclude='attic' --exclude='julia'  --exclude='.git' --exclude='.gitignore' --exclude='.DS_Store' /Users/cblackwell/cite/js/LSJ.js cblackwell@folio3.furman.edu:/home/cblackwell/lexica/

On the server:

	sudo rsync -avz --progress --exclude='attic' --exclude='julia'  --exclude='.git' --exclude='.gitignore' --exclude='.DS_Store' /home/cblackwell/lexica/LSJ.js/ /var/www/html/lsj

