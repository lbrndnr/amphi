import * as pdfjsLib from 'pdfjs-dist'
import * as pdfjsWorker from 'pdfjs-dist/build/pdf.worker' // bundles pdf.worker correctly
import * as pdfjsViewer from 'pdfjs-dist/web/pdf_viewer'

pdfjsLib.GlobalWorkerOptions.workerSrc = '../assets/pdf.worker.js'

window.onload = async () => {

	const container = document.querySelector('#pdf-wrapper');

	const url = "https://arxiv.org/pdf/2001.01653.pdf";
	const pdf = await pdfjsLib.getDocument(url).promise;

	// Load information from the first page.
	const page = await pdf.getPage(1);
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

	return pdfViewer.draw();
}

// window.onload = async () => {
// 	var url = "https://arxiv.org/pdf/2001.01653.pdf";
// 	const loadingTask = pdfjsLib.getDocument(url);
// 	const pdf = await loadingTask.promise;

// 	// Load information from the first page.
// 	const page = await pdf.getPage(1);

	// const params = {
	// 	scale: window.devicePixelRatio
	// };
	// const viewport = page.getViewport(params);

// 	// Apply page dimensions to the `<canvas>` element.
// 	const canvas = document.getElementById('pdf-canvas');
// 	const context = canvas.getContext('2d');
// 	canvas.height = viewport.height;
// 	canvas.width = viewport.width;

// 	// Render the page into the `<canvas>` element.
// 	const renderContext = {
// 		canvasContext: context,
// 		viewport: viewport,
// 	};

// 	// await page.render(renderContext);
// 	const renderTask = page.render(renderContext);

// 	// Wait for rendering to finish
//     renderTask.promise.then(function() {
// 		// Returns a promise, on resolving it will return text contents of the page
// 		return page.getTextContent();
// 	}).then(function(textContent) {  
// 		// Assign CSS to the textLayer element
// 		const textLayer = document.getElementById('text-layer');
  
// 		// textLayer.scale = window.devicePixelRatio;
// 		// textLayer.height = viewport.height;
// 		// textLayer.width = viewport.width;

// 		textLayer.style.left = canvas.offsetLeft + 'px';
// 		textLayer.style.top = canvas.offsetTop + 'px';
// 		textLayer.style.height = canvas.offsetHeight + 'px';
// 		textLayer.style.width = canvas.offsetWidth + 'px';
  
// 		// Pass the data to the method for rendering of text over the pdf canvas.
// 		pdfjsLib.renderTextLayer({
// 		  textContentSource: textContent,
// 		  container: textLayer,
// 		  viewport: viewport,
// 		  textDivs: []
// 		});
// 	});
// }