import * as pdfjsLib from 'pdfjs-dist';
import * as pdfjsViewer from 'pdfjs-dist/web/pdf_viewer';

const PDFViewer = {
	mounted() {
		const container = this.el;
		const url = container.getAttribute("pdf_url");
		pdfjsLib.getDocument(url).promise.then((pdf) => {
			pdf.getPage(1).then((page) => {
				// Load information from the first page.
				const eventBus = new pdfjsViewer.EventBus();
				const linkService = new pdfjsViewer.PDFLinkService({
					eventBus,
				});

				const params = {
					scale: window.devicePixelRatio
				};
				const viewport = page.getViewport(params);

				// Creating the page view with default parameters.
				const pdfViewer = new pdfjsViewer.PDFPageView({
					container,
					eventBus,
					linkService,
					l10n: pdfjsViewer.NullL10n,
					defaultViewport: viewport,
				});
				// Associates the actual page with the view, and drawing it
				pdfViewer.setPdfPage(page);
				linkService.setViewer(pdfViewer);

				pdfViewer.draw();
			})
		});
	}
}

export default PDFViewer;