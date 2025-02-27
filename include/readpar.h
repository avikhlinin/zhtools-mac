#include <sys/types.h>

#define RP_COMMENT     1
#define RP_PARSTRING   2
#define RP_IRAFSTRING  3
#define RP_PARCONT     4
#define RP_ENDGROUP    5
#define RP_INCLSTRING  6
#define RP_BEGGROUP    7

#define RP_UNDEFINED "undefined"
#define RP_PAR_FILE_ENV "MY_READPAR_FILE"

extern char* RP_Rem_Lead_Blanks (char *string);
extern int   RP_ParString (char *string);
extern int   RP_IRAFString (char *string);

extern int RP_InGroup();
extern int RP_PAR_Continued();

extern int IniReadPar(int argc,char **argv);
extern int get_command_line_par (char *name, char *value);
extern int get_cl_or_read_par (char *name, char *description, char *value);
extern int get_parameter_file_par (char *file, char *name, char *value);
extern int last_command_line_par_position ();
extern int last_parameter_val_position ();
extern int RP_q_expand_vars();
extern int RP_set_expand_vars (int flag);
extern int RP_chomp (char *string);
extern int defined(char *arg);
extern int yespar (char *name);
extern int nopar (char *name);
extern int defpar (char *name);
extern int set_default_par_value (char *name, char *value);
extern int lcase (char *string);
extern int iargc();
extern int getarg(int iarg, char *arg);
extern int string_iargc();
extern int string_getarg(int iarg, char *arg);
extern int RP_expand_variables (char *string);
extern int SetRPargv (int ipar, char *value);
extern int AllocRPargv (int npar);
extern int get_string_par (char *string, char *parname, char *parvalue);
extern int get_numbered_par (char *key, int n, char *value);

extern int RP_RecordType (char *line);
extern int RP_IsInGroup (int yes);
extern int RP_IsPAR_Continued (int yes);
extern int RP_Parse_Cont_String (char *line, char *value, char *comment, int  *valuecont);
extern int Clear_RP_Memory ();
extern int RP_Parse_Par_String (char *line,  char *name, char *value, char *comment, int  *valuecont);

extern int get_command_line_par_work (char *parname, char *parvalue);
extern int get_parameter_file_par_work (char *file, char *parname, char *parvalue);
extern int RP_Rem_PF_Pars (ino_t inode);
extern int RP_Parse_Group_String (char *line, char *name, char *comment); 
extern int RP_Push_New_PF_Par (ino_t inode, char *name, char *value);
extern int RP_Parse_IRAF_String (char *line, char *name, char *value, char *comment);

extern int RP_Parse_at_Line (char *line);
