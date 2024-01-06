include { featureCounts      } from '../modules/featureCounts.nf'
include { samtools_sort_name } from '../modules/samtools_sort_name.nf'


/**
 * Workflow to quantify mappings.
 *
 * This stage is commonly referred to as something like "counting reads."
 * We choose quantify because we find that this encompasses counting reads as well as other methods of quantification, e.g. pseudoalignment
 * 
 * @take alignments the sorted and indexed aligned/mapped reads channel of format [metadata, BAM, BAM.BAI].
 * @take annotations the reference annotations in GTF format. Can be gzipped.
 *
 * @emit quantify_log the output logs/summary/QC files from the quantification tool.
 */
workflow QUANTIFY {
    take:
        alignments
        annotations

    main:
        samtools_sort_name(alignments)
        featureCounts(
            samtools_sort_name.out.bamNameSorted,
            annotations
        )

    emit:
        quantify_log = featureCounts.out.countsSummary
}
