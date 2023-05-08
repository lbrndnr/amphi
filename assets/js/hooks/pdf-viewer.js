import * as pdfjsLib from 'pdfjs-dist';
import * as pdfjsViewer from 'pdfjs-dist/web/pdf_viewer';

const PDFViewer = {
	mounted() {	
		this.containerElement = this.el.querySelector("#pdf-container");
		this.viewerElement = this.el.querySelector(".pdfViewer");
		this.url = this.containerElement.getAttribute("pdf_url");

		this.initPDFViewer();
		pdfjsLib.getDocument(this.url).promise.then((pdf) => {
			this.viewer.setDocument(pdf);
		});
	},
	initPDFViewer() {
		const eventBus = new pdfjsViewer.EventBus();
		const linkService = new pdfjsViewer.PDFLinkService({
			eventBus,
		});	
		const container = this.containerElement;
		const viewer = this.viewerElement;
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