import * as pdfjsLib from 'pdfjs-dist';
import * as pdfjsViewer from 'pdfjs-dist/web/pdf_viewer';

const PDFViewer = {
	getContainerElement() {
		return this.el.querySelector("#pdf-container");
	},
	getViewerElement() {
		return this.el.querySelector(".pdfViewer");
	},
	getUrl() {
		return this.getContainerElement().getAttribute("pdf_url");
	},
	mounted() {	
		this.initPDFViewer();
		pdfjsLib.getDocument(this.getUrl()).promise.then((pdf) => {
			this.viewer.setDocument(pdf);
		});
	},
	initPDFViewer() {
		if (this.viewer != null) return;

		const eventBus = new pdfjsViewer.EventBus();
		const linkService = new pdfjsViewer.PDFLinkService({
			eventBus,
		});	
		const container = this.getContainerElement();
		const viewer = this.getViewerElement();
		this.viewer = new pdfjsViewer.PDFViewer({
			container,
			viewer,
			eventBus,
			linkService,
			l10n: pdfjsViewer.NullL10n
		});
		linkService.setViewer(this.viewer);
	}
}

export default PDFViewer;