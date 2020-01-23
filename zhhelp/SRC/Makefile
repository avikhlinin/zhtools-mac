DOC1 =  zhtools		\
	ad2rad rad2ad	\
	addimages	\
	createimg	\
	deproject	\
	fitsparsename	\
	fitspha		\
	imblock		\
	img2list	\
	imexam		\
	gtifits	gtiexp	\
	modifyheader	\
	projectimg	\
	sky2pix pix2sky	\
	sky2dss	dsscoord\
	wvdecomp

MAN1 = $(DOC1:%=../man1/%.1)

POD2MANFLAGS = --center="ZHTOOLS User guide" --release=" "

all: $(MAN1)

../man1/%.1: %.pod
	rm -f ../man1/$*.1
	pod2man $(POD2MANFLAGS) --section=1 $*.pod > ../man1/$*.1

clean:
	@$(RM) *.a *.so *.so.? *.dylib *.o errs *pure* .nfs* \
	foo* *~ *.log \#* TAGS *.E errors gmon.out *.pg *.bak \
	$(PROGS) a.out *.exe core
