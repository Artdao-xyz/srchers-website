<script>
	import { onMount } from "svelte";
    import "/src/style.css";
    import * as THREE from 'three';
    import { FirstPersonControls } from 'three/addons/controls/FirstPersonControls.js';
    import GUI from 'lil-gui'; 
    import { OrbitControls } from 'three/addons/controls/OrbitControls.js'
    import CustomShaderMaterial from 'three-custom-shader-material/vanilla'
    import vertexShader from '$lib/glsl/vertex.glsl'
    import fragmentShader from '$lib/glsl/fragment.glsl'
    import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js'
    import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js'
    import { ShaderPass } from 'three/examples/jsm/postprocessing/ShaderPass.js'
    import { FXAAShader } from 'three/examples/jsm/shaders/FXAAShader.js'
    import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js'
    import { FilmPass } from 'three/examples/jsm/postprocessing/FilmPass.js'
    import { GlitchPass } from 'three/examples/jsm/postprocessing/GlitchPass.js'
    import { BokehPass } from 'three/examples/jsm/postprocessing/BokehPass.js'

    let canvas, controls, active, srcFile;

    let loaded = false;
    
    onMount(() => {
        
        let logo = {'Logo' : 'srchrs-logo-4.svg'};
        srcFile = logo.Logo;

        active = window.location.hash === '#debug';

        const sizes = {
            width: window.innerWidth,
            height: window.innerHeight,
            pixelRatio: Math.min(window.devicePixelRatio, 2)
        };

        const scene = new THREE.Scene();

        const renderer = new THREE.WebGLRenderer({
            canvas,
            antialias: true,
            powerPreference: 'high-performance',
        })
        renderer.outputEncoding = THREE.sRGBEncoding;
        renderer.shadowMap.enabled = true
        renderer.shadowMap.type = THREE.PCFSoftShadowMap
        renderer.toneMapping = THREE.ACESFilmicToneMapping
        renderer.toneMappingExposure = 1.3
        renderer.setSize(sizes.width, sizes.height)
        renderer.setPixelRatio(sizes.pixelRatio);
        // scene.background = new THREE.Color('#ff')

        const resolutionPlane = { 'Resolution' : 500 }

        const geometry = new THREE.PlaneGeometry(3, 3, resolutionPlane.Resolution, resolutionPlane.Resolution)
        geometry.deleteAttribute('uv')
        geometry.deleteAttribute('normal')
        geometry.rotateX(- Math.PI * 0.5)
        // geometry.translate(0.0, 0.0, 0.0 )

        
        const uniforms = {
            uTime: new THREE.Uniform(0),
            uPositionFrequency: new THREE.Uniform(0.15),
            uStrength: new THREE.Uniform(0.35),
            uWarpFrequency: new THREE.Uniform(2.5),
            uWarpStrength: new THREE.Uniform(1.4),
        }

        const material = new CustomShaderMaterial({
            // CSM
            baseMaterial: THREE.MeshStandardMaterial,
            vertexShader: vertexShader,
            fragmentShader: fragmentShader,
            uniforms: uniforms,
            silent: true,

            // MeshPhysicalMaterial
            metalness: 0,
            roughness: 0.5,
            color: '#ffffff',
        })

        const terrain = new THREE.Mesh(geometry, material)
        scene.add(terrain)

        let directionalLight = new THREE.DirectionalLight('#ffffff', 5)
        directionalLight.position.set(6.25, 3, 4)
        directionalLight.castShadow = true
        directionalLight.shadow.mapSize.set(1024, 1024)
        directionalLight.shadow.camera.near = 0.1
        directionalLight.shadow.camera.far = 30
        directionalLight.shadow.camera.top = 8
        directionalLight.shadow.camera.right = 8
        directionalLight.shadow.camera.bottom = -8
        directionalLight.shadow.camera.left = -8
        scene.add(directionalLight)
        
        const ambientLight = new THREE.AmbientLight('#ffffff', .5)
        scene.add(ambientLight)

        const camera = new THREE.PerspectiveCamera(30, sizes.width / sizes.height, 0.1, 100)
        camera.position.set(0, 0.25, 0);
        camera.rotation.x = -Math.PI / 7;
        //debug view
        // camera.position.set(0, 10.20, 0);
        // camera.rotation.x = -Math.PI / 2;

        scene.add(camera)

        //OrbitControls
        // const controls = new OrbitControls(camera, canvas)
        // controls.enableDamping = true

        //FirstPersonControls
        controls = new FirstPersonControls(camera, renderer.domElement);
        controls.lookVertical = false;
        controls.movementSpeed = 0.0;
        controls.lookSpeed = .002;        

        const fog = new THREE.Fog('#000000', 0.001, 1.25);
        scene.fog = fog;

        const composer = new EffectComposer(renderer);
        composer.setSize(sizes.width, sizes.height);
        composer.setPixelRatio(sizes.pixelRatio);
        composer.addPass(new RenderPass(scene, camera));

        const effectFXAA = new ShaderPass(FXAAShader);
        effectFXAA.uniforms['resolution'].value.set(1 / ( sizes.width * sizes.pixelRatio ), 1 / ( sizes.height * sizes.pixelRatio ));
        composer.addPass(effectFXAA);

        const bokehPass = new BokehPass(scene, camera, {
            focus: 0.20,
            aperture: 0.0065,
            maxblur: 0.005,
            width: sizes.width,
            height: sizes.height
        });
        composer.addPass(bokehPass);

        const bloomPass = new UnrealBloomPass(new THREE.Vector2(sizes.width, sizes.height), 1.5, 0.4, 1.25);
        bloomPass.enabled = false;
        composer.addPass(bloomPass);

        const filmPass = new FilmPass(0.35, 0.025, 648, false);
        filmPass.enabled = false;
        composer.addPass(filmPass);

        onresize = () => {
            sizes.width = window.innerWidth;
            sizes.height = window.innerHeight;

            camera.aspect = sizes.width / sizes.height;
            camera.updateProjectionMatrix();

            controls.handleResize();
            renderer.setSize(sizes.width, sizes.height);
            
        };

        const clock = new THREE.Clock()
        let uTimeAmount = 0.20;

        const tick = () => {
            const elapsedTime = clock.getElapsedTime()

            uniforms.uTime.value = elapsedTime * uTimeAmount;

            if (controls) {controls.update(.05)};
            // renderer.render(scene, camera)
            composer.render()
            window.requestAnimationFrame(tick)
        }
        tick()

        // onmousemove = (event) => {
        //     let screenWidth = sizes.width;
        //     let cursorX = event.clientX;

        //     // If cursor is on the left side of the screen
        //     if (cursorX < screenWidth / 2) {
        //         // Trigger action for left side
        //         console.log("Cursor is on the left side of the screen.");
        //         // Your code for left side action here
        //     } else {
        //         // Trigger action for right side
        //         console.log("Cursor is on the right side of the screen.");
        //         // Your code for right side action here
        //     }
        // };

            loaded = true;
        
        if (active) {
            let gui = new GUI();

            const logoFolder = gui.addFolder('Logo')
            logoFolder.add(logo, 'Logo', ['srchrs-logo-1.svg', 'srchrs-logo-2.svg', 'srchrs-logo-3.svg', 'srchrs-logo-4.svg']).onChange((value) => {
                srcFile = value;
            })

            const folderShader = gui.addFolder('Shader')        
            // gui.add( resolutionPlane, 'Resolution', [ 50, 100, 200, 500 ] ).onChange((value) => {
            //     console.log(value)
            //     // const geometry = new THREE.PlaneGeometry(3, 3, value, value)
            //     geometry.dispose(); // Clean up previous geometry
            //     // terrain.geometry = geometry;
            //     }
            // )

            folderShader.add(uniforms.uPositionFrequency, 'value', 0.06, 0.15, 0.001).name('uPositionFrequency')
            folderShader.add(uniforms.uStrength, 'value', 0.15, 0.35, 0.001).name('uStrength')
            folderShader.add(uniforms.uWarpFrequency, 'value', 0, 8, 0.001).name('uWarpFrequency')
            folderShader.add(uniforms.uWarpStrength, 'value', 0, 4, 0.001).name('uWarpStrength')
            // add a parameter to increase uTimeAmount
            folderShader.add({ uTimeAmount: uTimeAmount }, 'uTimeAmount', 0, 5, 0.001).name('uVelocity').onChange((value) => {
                uTimeAmount = value
            })
            const lightFolder = gui.addFolder('Light')
            lightFolder.add(directionalLight, 'intensity', 0, 7, 0.001).name('intensity');
            const cameraFolder = gui.addFolder('Camera')
            cameraFolder.add(camera.position, 'y', 0, 10, 0.001).name('Y')

            const postProcessFolder = gui.addFolder('Post Process')
            postProcessFolder.add(filmPass, 'enabled').name('Film Pass')
            postProcessFolder.add(effectFXAA, 'enabled').name('FXAA')
            postProcessFolder.add(bloomPass, 'enabled').name('Bloom')
            postProcessFolder.add(bloomPass, 'threshold', 0, 1, 0.001).name('Bloom Threshold')
            postProcessFolder.add(bokehPass, 'enabled').name('Bokeh')
            postProcessFolder.add(fog, 'far', 0.001, 15, 0.001).name('Fog Far')
        }
    });
</script>

<canvas class="-z-10" bind:this={canvas}></canvas>

<!-- <h1 class="text-blue-400 absolute left-1/2 -translate-x-1/2 top-1/2 -translate-y-1/2 text-6xl select-none">SRCHRS</h1> -->
<!-- create a img tag placed in the center -->
{#if loaded}
    <img src={`${srcFile}`} class="scale-50 md:scale-100 absolute left-1/2 -translate-x-1/2 top-1/2 -translate-y-1/2 z-10" alt="logo">

    <!-- add another img at 3/4 of the canvas from top to bottom -->
    <img src="/launching.svg" class="scale-50 md:scale-100 absolute left-1/2 -translate-x-1/2 top-2/3 -translate-y-2/3  z-10" alt="logo">
{/if}