% APP_DEFAULTREPORTTEMPLATE
% Returns structure default reporting components
%
% Usage:
%   >> T = app_defaultreporttemplate();
%
% Inputs:
%   none
%
% Outputs:
%   'T' - [struct] structure containing default reporting template.
%
% See also STRUCT.

% Authors:
%   Rick Wassing, Woolcock Institute of Medical Research, Sydney, Australia
%
% History:
%   Created 2024-12-20, Rick Wassing

% Cicada (C) 2023 by Rick Wassing is licensed under
% Attribution-NonCommercial-ShareAlike 4.0 International
% This license requires that reusers give credit to the creator. It allows
% reusers to distribute, remix, adapt, and build upon the material in any
% medium or format, for noncommercial purposes only. If others modify or
% adapt the material, they must license the modified material under
% identical terms.

function T = app_defaultreporttemplate()
% -------------------------------------------------------------------------
T = struct();
T.templateId = getuuid();
T.created = datetime2iso(datetime('now'), 'omitmilliseconds');
T.modified = T.created;
T.userId = '123';
T.name = 'My Report';
% -------------------------------------------------------------------------
T.style = struct();
T.style.page.margin.top = 1.27;
T.style.page.margin.bottom = 1.27;
T.style.page.margin.left = 2.54;
T.style.page.margin.right = 2.54;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.style.row.backgroundColor = '#ffffff';
T.style.row.margin.top = 0;
T.style.row.margin.bottom = 0;
T.style.row.margin.left = 0;
T.style.row.margin.right = 0;
T.style.row.padding.top = 0;
T.style.row.padding.bottom = 0;
T.style.row.padding.left = 0;
T.style.row.padding.right = 0;
T.style.row.border.type = 'none';
T.style.row.border.width = 0;
T.style.row.border.color = '#000000';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.style.paragraph.fontFamily = 'Helvetica';
T.style.paragraph.fontSize = 12;
T.style.paragraph.fontColor = '#000000';
T.style.paragraph.fontWeight = 'normal';
T.style.paragraph.fontStyle = 'normal';
T.style.paragraph.textAlign = 'left';
T.style.paragraph.lineHeight = 1.5;
T.style.paragraph.spacing = 10;
T.style.paragraph.backgroundColor = 'none';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.style.h1.fontFamily = 'Helvetica';
T.style.h1.fontSize = 18;
T.style.h1.fontColor = '#000000';
T.style.h1.fontWeight = 'bold';
T.style.h1.fontStyle = 'normal';
T.style.h1.textAlign = 'left';
T.style.h1.lineHeight = 1;
T.style.h1.spacing = 10;
T.style.h1.backgroundColor = 'none';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.style.h2.fontFamily = 'Helvetica';
T.style.h2.fontSize = 14;
T.style.h2.fontColor = '#000000';
T.style.h2.fontWeight = 'bold';
T.style.h2.fontStyle = 'normal';
T.style.h2.textAlign = 'left';
T.style.h2.lineHeight = 1;
T.style.h2.spacing = 10;
T.style.h2.backgroundColor = 'none';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.style.h3.fontFamily = 'Helvetica';
T.style.h3.fontSize = 14;
T.style.h3.fontColor = '#000000';
T.style.h3.fontWeight = 'bold';
T.style.h3.fontStyle = 'italic';
T.style.h3.textAlign = 'left';
T.style.h3.lineHeight = 1;
T.style.h3.spacing = 10;
T.style.h3.backgroundColor = 'none';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.style.h4.fontFamily = 'Helvetica';
T.style.h4.fontSize = 14;
T.style.h4.fontColor = '#000000';
T.style.h4.fontWeight = 'normal';
T.style.h4.fontStyle = 'italic';
T.style.h4.textAlign = 'left';
T.style.h4.lineHeight = 1;
T.style.h4.spacing = 10;
T.style.h4.backgroundColor = 'none';
% -------------------------------------------------------------------------
T.layout.header.columns(1).columnId = getuuid();
T.layout.header.columns(1).width = 3;
T.layout.header.columns(1).content = struct();
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.header.columns(2).columnId = getuuid();
T.layout.header.columns(2).width = 9;
T.layout.header.columns(2).content = struct();
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.header.columns(1).content.contentId = getuuid();
T.layout.header.columns(1).content.type = 'image';
T.layout.header.columns(1).content.props.src = 'cicadalogo.png';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.header.columns(2).content.contentId = getuuid();
T.layout.header.columns(2).content.type = 'h1';
T.layout.header.columns(2).content.props.text = 'Actigraphy Report';
T.layout.header.columns(2).content.props.textAlign = 'center';
% -------------------------------------------------------------------------
T.layout.footer.pageNumbers = true;
T.layout.footer.dateStamp = true;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.footer.columns(1).columnId = getuuid();
T.layout.footer.columns(1).width = 12;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.footer.columns(1).content(1).contentId = getuuid();
T.layout.footer.columns(1).content(1).type = 'paragraph';
T.layout.footer.columns(1).content(1).props.fontSize = 9;
T.layout.footer.columns(1).content(1).props.text = '99 Activity Drive, Circadinopolis, NSW Australia\nABN 12 345 678 901\nwww.mysite.org.au';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.footer.columns(1).content(2).contentId = getuuid();
T.layout.footer.columns(1).content(2).type = 'paragraph';
T.layout.footer.columns(1).content(2).props.fontSize = 9;
T.layout.footer.columns(1).content(2).props.fontColor = '#fcfcfc';
T.layout.footer.columns(1).content(2).props.text = 'Generated by Cicada (C) 2023. Licensed under Attribution-NonCommercial-ShareAlike 4.0 International';
% -------------------------------------------------------------------------
T.layout.body.rows(1).rowId = getuuid();
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.body.rows(1).columns.columnId = getuuid();
T.layout.body.rows(1).columns.width = 12;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.body.rows(1).columns.content(1).contentId = getuuid();
T.layout.body.rows(1).columns.content(1).type = 'h2';
T.layout.body.rows(1).columns.content(1).props.text = 'Patient information';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.body.rows(1).columns.content(2).contentId = getuuid();
T.layout.body.rows(1).columns.content(2).type = 'form';
T.layout.body.rows(1).columns.content(2).props.items = {'Patient Name', 'Patient ID', 'Date of Birth', 'Referring doctor', 'Presenting problem'};
% -------------------------------------------------------------------------
T.layout.body.rows(2).rowId = getuuid();
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.body.rows(2).columns(1).columnId = getuuid();
T.layout.body.rows(2).columns(1).width = 6;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.body.rows(2).columns(1).content(1).contentId = getuuid();
T.layout.body.rows(2).columns(1).content(1).type = 'h2';
T.layout.body.rows(2).columns(1).content(1).props.text = 'Technical assessment';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.body.rows(2).columns(1).content(2).contentId = getuuid();
T.layout.body.rows(2).columns(1).content(2).type = 'text';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.body.rows(2).columns(1).content(3).contentId = getuuid();
T.layout.body.rows(2).columns(1).content(3).type = 'form';
T.layout.body.rows(2).columns(1).content(3).props.items = {'Caffeine intake', 'Medication', 'Alcohol', 'Exercise', 'Naps', 'Other factors'};
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.body.rows(2).columns(2).columnId = getuuid();
T.layout.body.rows(2).columns(2).width = 6;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.body.rows(2).columns(2).content(1).contentId = getuuid();
T.layout.body.rows(2).columns(2).content(1).type = 'h2';
T.layout.body.rows(2).columns(2).content(1).props.text = 'Clinical recommendations';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.body.rows(2).columns(2).content(2).contentId = getuuid();
T.layout.body.rows(2).columns(2).content(2).type = 'text';
% -------------------------------------------------------------------------
T.layout.body.rows(3).rowId = getuuid();
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.body.rows(3).columns(1).columnId = getuuid();
T.layout.body.rows(3).columns(1).width = 12;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.body.rows(3).columns(1).content(1).contentId = getuuid();
T.layout.body.rows(3).columns(1).content(1).type = 'h2';
T.layout.body.rows(3).columns(1).content(1).props.text = 'Actogram';
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
T.layout.body.rows(3).columns(1).content(2).contentId = getuuid();
T.layout.body.rows(3).columns(1).content(2).type = 'actogram';

end