Notefish is a note-taking app which behaves a lot like Google Keep, but with
many more features.

### Login

The user logs-in with an email and password, or username and password. The user
must pick a unique email and unique username. The email must be verified before
access is granted.

### Spaces

Every note belongs to a particular space. A space is like a workspace. The user
has a default space, where notes are added to by default. The user can create
more spaces, and these spaces can be collaborative.

### Folders

The user can create folders inside a space, or folders inside of folders. Then
notes exist inside the root space, or within a folder. A folder's full path
must be unique e.g. for A/B/C, C must be the only folder called C inside folder
B.

Folders are displayed in the left sidebar, underneath the space. Folders are
collapsed by default, but they can be expanded to show the contents. The
subfolders in a space or a folder always show at the top, with all notes in the
current folder being listed below subfolders. Some notes are loaded immediately
when the folder is expanded, but not all. The user can click to load more notes
in a folder. If a folder is deleted, the user is given an option to move the
notes to the root space, or delete them all as well as the folder.

### Main View

The main view in Notefish is simply the results of the unified search bar. The
search bar can bring up any note you have access to, and the default 'recently
edited notes' view is just a particular default search query. The user can view
notes in the search results in a few different ways. By default, notes are
viewed as sticky notes, tiling down the page with a fixed margin between them.
If the note has a title, it is displayed in large text at the top of the note.
The contents of the note are briefly displayed, and cut off at a maximum length.
An ellipsis shows that there is more to read, and the note can be clicked on
to enter the Note Editor and view the full note.

The search bar can return notes or blocks as results. A 'note' in the database
does not have the note body, only a title. The note can have fields and include
tags in the title. For example...

title  : 'Company ABC #todo #productivity'
fields : 'Due Date' => '15/08/2022'
         'Assigned' => '@john.doe'

The search bar can return notes that match 'by metadata' (title, tags, etc.)
The contents of the note are stored in blocks. Consider the following note
text. Ignore the quotation marks, they are only present to label the contents
of the note.

"""
This is a block in the Note.
This text is in the same block.

This text is in a new block.
- This text is also in a new block, since it is indented by the hyphen.
* This text is also in a new block. The client renders these as bulletpoints.
  * This text is in a 'child' block, because the note is indented in a list.
"""

In the database, the following blocks would exist.

1. This is a block in the Note.\nThis text is in the same block.
2. This text is in a new block.
3. This text is also in a new block, since it is indented by the hyphen.
4. This text is also in a new block. The client renders these as bulletpoints.
5. This text is in a 'child' block, because the note is indented in a list.

A search query can return any of these blocks *specifically*. This is called a
search match 'by content'. The client would only have access to the block text
unless it explicitly fetches the entire note's contents.

The benefit is that a note can use a tag or a reference, and that particular
block will be linked in the database. Consider the following note text.

"""
This is some block of text, which doesn't contain any tags.

This is a #note #block which uses #tags and [[A Note Reference]].

This is another block which uses [[A Note Reference]], but no tags.
"""

The title of this note is 'Some #note title'

Let the dollar sign represent a query. The results are shown on each line
after. Consider the following queries...

$ `#note 'This is a'`
- (by metadata) 'Some note title' "This is some block of text..."
- (by content) 'Some note title' "This is a #note #block which uses #tags..."

The user has the option to merge matches from the same note, but by default
these are shown separately.

$ `[[A Note Reference]]`
- (by content) 'Some note title' "This is a #note #block which uses #tags..."
- (by content) 'Some note title' "This is another block which uses [[A Note..."

The effect of a reference like [[A Note Reference]] is a referential link. If a
note called 'A Note Reference' exists, it is now linked to 'Some note title'.
If the user opens the Note Editor for 'A Note Reference', they will see a list
of referential links at the top before the content. It will show a preview of
the specific block (and text) which referenced the note. 

### Search Bar

The search bar is always present and can return notes or blocks from any open
space. Here are some examples.

Note or block must have these tags.

$ `#must #include #these #tags`

Note field must have this value.

$ `'Due Date'='15/08/22'`

Note must have this author (notes may have multiple authors.)

$ `@john.doe`

Prioritize notes which contain this text (keyword match.)

$ `list of keywords`

Return notes which are in the archive.

$ `archived: yes`

Return notes from this place (space or folder.)

$ `in: My Space`

$ `in: Notefish`

$ `in: A/B/C`

Sort search results in this way.

$ `some keyword list, sort: edited`

$ `some keyword list, sort: created, order: ascending` 

The default note view. This is displayed whenever the user opens the app.

$ `in: My Space sort: edited`

The searchbar also has a view option for search results. This is not included
in the search query, but it is present as a dropdown somewhere near the bar.

Methods: sticky note (default), list, mood board, kanban

The 'sticky note' view is Google Keep style, and shows an image if it exists. A
title is shown if it exists (notes can omit a title.) The body is always
previewed, at the bottom in a white container if there is an image.

The 'mood board' view just displays the first image in the note, and does not
show text unless you hover over it.

The 'kanban' view opens a page with a single Uncategorized column. The page
lets you add a series of #tags to sort by. Any notes returned to the query are
sorted under a #tag column according to which tags it has.

Any search query, with its view option, can be saved for later usage. This is
saved in the space, above the subfolders. It can be moved to a subfolder.
Clicking on the view simply fills the search bar with the query.

There is an add note button above the note list, however it is displayed, if
you have the privileges to create a new note in this space.

Double clicking on a space or folder brings up the default query for that
object. The default query for a space or folder can be changed in its settings,
alongside its privileges. For example, if you wanted to show a bunch of images
in a space as a mood board by default, you could.

### Note Editor

When clicking on the bottom-right 'expand' button for a note, or just double
clicking it in general, the client will open the note editor for that note.

The note editor has the appearance of a rich-formatting text editor. Text can
be put into bold, italics or code blocks. The font family and size can be
changed, but these are not special formatting on the note. The note is always
stored in plaintext. Bold is represented as `<b>`bold`</b>`, italics as
`<i>`italics`</i>` and codeblocks wrapped like ``codeblocks``. The font settings are
just a preference, and change your font settings globally for every note.
There are two editing modes for the note editor - rich and plaintext. The rich
editing mode converts dashes and astrisks to bullet points. [[Note References]]
and #tags are highlighted. Bold, italics and code blocks are rendered. In the
plaintext editing mode, this is all stripped away and you see the raw content.
This may be in a monospace font or not depending on user preferences.

### Privileges

A user cannot access notes they do not have the privileges to read. A user can
have read-only privileges, read-and-write privileges or absolute privileges. 
Absolute privileges allow the user to move or delete the note. If the privileges
for a note are not set, it inherits the privileges from the closest object
in the hierarchy which has explicit privileges. For example, if a note has
no privileges set, it will try to inherit them from the folder. If that folder
has no privileges set, it will try to inherit them from the next folder up.
All the way up to the underlying space.

Privileges can be set on all notes, folders and spaces - other than the user's
default space. The default space is always private. When setting the privileges
for a note, folder or space, the user can get a link to it. The link can be
used anonymously (read-only) or logged-in. If the user is logged-in, using the
link will add it to the user's 'open spaces'. These are all the spaces that the
user has listed, at all times, in their sidebar. It is possible to remove all
spaces from the sidebar other than the default space, and spaces can be
collapsed the same as folders. The user can add a space back to their open
spaces by using the link.

A note, folder or space can also be shared with specific users, either by email
address or by username. This access can be revoked at any time, and the access
is either read-only, read-and-write or absolute (privilege level names subject
to change.)

### Collaborative Editing

The note editor will support collaborative live editing. I have not yet
finalized the design for this, but I am imagining it will be based on a p2p
architecture.

### Preferences

Other than that, there are preferences for the user's client behaviour. The
preferences menu lets the user choose a theme, or create their own (backlog.)
They can set the font family and font size they'd like to see notes in, in
sticky note form and in the note editor. 
