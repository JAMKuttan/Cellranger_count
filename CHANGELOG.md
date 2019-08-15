# v1.2.0
**User Facing**
* Add Cellranger Version 3.1.0
* Add human/mouse farmyard reference Version 3.1.0 from 10x
* Add Vizapp (shiny)
* Fix mutiqc error
* Add MIT License

**Background**
* Add CI Artifacts

*Known Bugs*
* Vizapp does not yet work for Astrocyte

# v1.1.0
**User Facing**
* Make report (multiqc) for cellranger qc output, version, references

**Background**
* Add changelog
* Add check for space in genomeLocationFull (cellranger cannot handle) in bash script
* Move module loads to process setup level code
* Add Jeremy Mathews to author list
* Apply style guide
* Add pytests for ouptuts
* Test for incompatible params (kitVersion=3 AND version=2.1.1)

*Known Bugs*
