<template>
    <div class="outBlock">
        <div class="btnBlock">
            <button id="startButton" @click="startRecording" :disabled="isRecording"
                :style="{ background: isRecording ? '#c5c5c5' : '#ff5959' }">開始錄影</button>
            <button id="stopButton" @click="stopRecording" :disabled="!isRecording"
                :style="{ background: !isRecording ? '#c5c5c5' : '#097424' }">停止錄影</button>
            <div class="videoNameBlock">
                <label for="vdName">影片名稱</label>
                <input id="vdName" type="text" v-model="videoName">
            </div>
        </div>
        <div>
            <div v-if="isRecording === true || isRecording === null">
                <!-- 錄制前的影片 -->
                <h3 class="title">預覽畫面</h3>
                <p class="statusMessageStyle">{{ statusMessage }}</p>
                <video id="preview" ref="previewVideo" src="" autoplay></video>
            </div>
            <div v-else-if="isRecording === false">
                <!-- 錄完的影片 -->
                <h2 class="title">錄影完成</h2>
                <a ref="downloadLink" class="downloadLinkStyle" :href="videoUrl" :download="videoName">下載影片</a>
                <video id="recordedVideo" ref="recordedVideo" controls :src="videoUrl"></video>
            </div>
            <div v-else-if="isRecording === null">

            </div>
        </div>
    </div>
</template>

<script setup>
import { ref } from 'vue';



//用於儲存影像和音訊的串流（MediaStream）物件。
let stream = null;
//用於錄製影片的 MediaRecorder 物件。
let mediaRecorder = null;
//儲存已錄製的影片片段（chunks）。
let recordedChunks = ref([]);
//追蹤是否正在進行錄製，如果是則為 true，否則為 false。
const isRecording = ref(null);
//顯示錄製狀態的訊息。
const statusMessage = ref('');
//儲存已錄製影片的 URL
const videoUrl = ref('');

const previewVideo = ref(null);

// 影片名稱
const videoName = ref('錄製影片')

// 合併螢幕截圖影像和麥克風錄音
async function mergeStreams() {
    try {
        const screenStream = await navigator.mediaDevices.getDisplayMedia({
            video: true,
            audio: true,
        });
        const audioStream = await navigator.mediaDevices.getUserMedia({
            audio: true,
        });
        // 創建MediaStream來合併音軌
        const mergedStream = new MediaStream();
        screenStream.getVideoTracks().forEach((track) => mergedStream.addTrack(track));
        audioStream.getAudioTracks().forEach((track) => mergedStream.addTrack(track));

        return mergedStream;
    } catch (error) {
        console.error("Error merging streams:", error);
        return null;
    }
}


// 啟動錄影
const startRecording = async () => {
    alert("選 整個螢幕畫面 並勾選 分享系統音訊");
    try {
        const mergedStream = await mergeStreams();
        if (mergedStream) {
            recordedChunks.value = [];
            previewVideo.value.srcObject = mergedStream;
            mediaRecorder = new MediaRecorder(mergedStream);

            mediaRecorder.ondataavailable = (event) => {
                if (event.data.size > 0) {
                    recordedChunks.value.push(event.data);
                }
            };
            // 開始錄影
            mediaRecorder.onstart = () => {
                statusMessage.value = "正在錄影...";
                isRecording.value = true;
            };
            // 結束錄影
            mediaRecorder.onstop = () => {
                statusMessage.value = "";
                isRecording.value = false;
                const blob = new Blob(recordedChunks.value, { type: "video/mp4" });
                videoUrl.value = URL.createObjectURL(blob);
            };

            mediaRecorder.start();
        }
    } catch (err) {
        console.error("無法啟動錄影：", err);
    }
};

// 停止錄影
const stopRecording = () => {
    if (mediaRecorder && mediaRecorder.state !== "inactive") {
        mediaRecorder.stop();
        if (stream) {
            stream.getTracks().forEach((track) => track.stop());
        }
        createDownloadLink();
    }
};

// 創建下載連結
const createDownloadLink = () => {
    const blob = new Blob(recordedChunks.value, { type: "video/mp4" });
    const url = URL.createObjectURL(blob);

};


</script>

<style lang="scss" scoped>
.outBlock {
    width: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
}
.videoNameBlock{
    display: flex;
    flex-direction: column;
    padding: 10px;
    text-align: left;
    label{
        color: #fff;
    }
    input{
        padding: 10px;
        font-size: 20px;
        background: none;
        border: none;
        color: #fff;
        border-bottom: 2px solid #fff;
    }
}
.btnBlock {
    display: flex;
    flex-direction: column;
    margin: 0 10px;
    button {
        word-break: keep-all;
        padding: 20px 30px;
        font-size: 34px;
        margin: 20px;
        border: none;
        color: #fff;
        border-radius: 11px;
        cursor: pointer;

        &#startButton {
            color: #fff;
            background: #ff5959;
        }

        &#stopButton {
            color: #fff;
            background: #097424;
        }
    }


}

video {
    width: 600px;
    height: 400px;
    background: #000000;
}

@keyframes flashingLight {

    0%,
    100% {
        color: #ff9f20;
    }

    50% {
        color: black;
    }
}

.statusMessageStyle {
    color: #fff;
    animation: flashingLight 1s infinite;
}

.title {
    color: #fff;
    font-weight: bold;
}

.downloadLinkStyle {
    width: 140px;
    margin: 10px auto;
    background: #ec781a;
    padding: 15px;
    color: #fff;
    display: block;
    border-radius: 11px;
    cursor: pointer;
    :hover{
        background: #9c4e0e;
    }

}</style>