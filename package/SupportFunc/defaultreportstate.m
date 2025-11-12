function s = defaultreportstate()

s = struct();

s.Id = getuuid('full');

s.style = struct();
s.style.page = struct();
s.style.logo = struct();
s.style.title = struct();
s.style.h1 = struct();
s.style.paragraph = struct();
s.style.small = struct();

s.style.page.margin = struct();
s.style.page.margin.top = 1.27;
s.style.page.margin.right = 2.54;
s.style.page.margin.bottom = 1.27;
s.style.page.margin.left = 2.54;

s.style.logo.width = 1; % cm

s.style.title.fontFamily = 'Georgia';
s.style.title.fontSize = 14;
s.style.title.fontColor = '#337380';
s.style.title.fontWeight = 'bold';
s.style.title.fontStyle = 'normal';
s.style.title.textAlign = 'left';
s.style.title.lineHeight = 1;

s.style.h1.fontFamily = 'Georgia';
s.style.h1.fontSize = 11;
s.style.h1.fontColor = '#337380';
s.style.h1.fontWeight = 'bold';
s.style.h1.fontStyle = 'normal';
s.style.h1.textAlign = 'left';
s.style.h1.lineHeight = 1;

s.style.paragraph.fontFamily = 'Helvetica';
s.style.paragraph.fontSize = 11;
s.style.paragraph.fontColor = '#262626';
s.style.paragraph.fontWeight = 'normal';
s.style.paragraph.fontStyle = 'normal';
s.style.paragraph.textAlign = 'left';
s.style.paragraph.lineHeight = 1;

s.style.small.fontFamily = 'Helvetica';
s.style.small.fontSize = 9;
s.style.small.fontColor = '#808080';
s.style.small.fontWeight = 'normal';
s.style.small.fontStyle = 'normal';
s.style.small.textAlign = 'left';
s.style.small.lineHeight = 1;

s.content = struct();
s.content.header = struct();

s.content.header.ReportTitle = 'Cicada Report';
s.content.header.InstituteName = 'Buzzington University';
s.content.header.InstituteAddress = '24 Sleep Circuit\nBuzzington, REM, 2000\nP: (01) 1234 5678\nE: info@company.org';

end
