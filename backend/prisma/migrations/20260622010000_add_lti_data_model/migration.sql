-- This migration extends the existing Prisma schema.
-- It assumes the current tables already exist: "Candidate", "Education",
-- "WorkExperience" and "Resume".
-- It is not intended to be the initial migration for an empty database.

-- CreateTable
CREATE TABLE "Company" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(150) NOT NULL,

    CONSTRAINT "Company_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Employee" (
    "id" SERIAL NOT NULL,
    "companyId" INTEGER NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "role" VARCHAR(100) NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "Employee_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Position" (
    "id" SERIAL NOT NULL,
    "companyId" INTEGER NOT NULL,
    "interviewFlowId" INTEGER NOT NULL,
    "title" VARCHAR(150) NOT NULL,
    "description" TEXT NOT NULL,
    "status" VARCHAR(50) NOT NULL DEFAULT 'draft',
    "isVisible" BOOLEAN NOT NULL DEFAULT false,
    "location" VARCHAR(150) NOT NULL,
    "jobDescription" TEXT NOT NULL,
    "requirements" TEXT NOT NULL,
    "responsibilities" TEXT NOT NULL,
    "salaryMin" DECIMAL(10,2),
    "salaryMax" DECIMAL(10,2),
    "employmentType" VARCHAR(100) NOT NULL,
    "benefits" TEXT,
    "companyDescription" TEXT,
    "applicationDeadline" DATE,
    "contactInfo" VARCHAR(255) NOT NULL,

    CONSTRAINT "Position_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "Position_salary_range_check" CHECK ("salaryMin" IS NULL OR "salaryMax" IS NULL OR "salaryMax" >= "salaryMin")
);

-- CreateTable
CREATE TABLE "InterviewFlow" (
    "id" SERIAL NOT NULL,
    "description" TEXT NOT NULL,

    CONSTRAINT "InterviewFlow_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "InterviewStep" (
    "id" SERIAL NOT NULL,
    "interviewFlowId" INTEGER NOT NULL,
    "interviewTypeId" INTEGER NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "orderIndex" INTEGER NOT NULL,

    CONSTRAINT "InterviewStep_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "InterviewType" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,

    CONSTRAINT "InterviewType_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Application" (
    "id" SERIAL NOT NULL,
    "positionId" INTEGER NOT NULL,
    "candidateId" INTEGER NOT NULL,
    "applicationDate" DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" VARCHAR(50) NOT NULL DEFAULT 'submitted',
    "notes" TEXT,

    CONSTRAINT "Application_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Interview" (
    "id" SERIAL NOT NULL,
    "applicationId" INTEGER NOT NULL,
    "interviewStepId" INTEGER NOT NULL,
    "employeeId" INTEGER NOT NULL,
    "interviewDate" DATE NOT NULL,
    "result" VARCHAR(50),
    "score" INTEGER,
    "notes" TEXT,

    CONSTRAINT "Interview_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "Interview_score_check" CHECK ("score" IS NULL OR ("score" >= 0 AND "score" <= 100))
);

-- CreateIndex
CREATE UNIQUE INDEX "Company_name_key" ON "Company"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Employee_email_key" ON "Employee"("email");

-- CreateIndex
CREATE INDEX "Employee_companyId_isActive_idx" ON "Employee"("companyId", "isActive");

-- CreateIndex
CREATE UNIQUE INDEX "Position_interviewFlowId_key" ON "Position"("interviewFlowId");

-- CreateIndex
CREATE INDEX "Position_companyId_idx" ON "Position"("companyId");

-- CreateIndex
CREATE INDEX "Position_status_isVisible_idx" ON "Position"("status", "isVisible");

-- CreateIndex
CREATE INDEX "Position_applicationDeadline_idx" ON "Position"("applicationDeadline");

-- CreateIndex
CREATE UNIQUE INDEX "InterviewStep_interviewFlowId_orderIndex_key" ON "InterviewStep"("interviewFlowId", "orderIndex");

-- CreateIndex
CREATE INDEX "InterviewStep_interviewTypeId_idx" ON "InterviewStep"("interviewTypeId");

-- CreateIndex
CREATE UNIQUE INDEX "InterviewType_name_key" ON "InterviewType"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Application_positionId_candidateId_key" ON "Application"("positionId", "candidateId");

-- CreateIndex
CREATE INDEX "Application_candidateId_idx" ON "Application"("candidateId");

-- CreateIndex
CREATE INDEX "Application_positionId_status_idx" ON "Application"("positionId", "status");

-- CreateIndex
CREATE INDEX "Application_applicationDate_idx" ON "Application"("applicationDate");

-- CreateIndex
CREATE UNIQUE INDEX "Interview_applicationId_interviewStepId_key" ON "Interview"("applicationId", "interviewStepId");

-- CreateIndex
CREATE INDEX "Interview_employeeId_interviewDate_idx" ON "Interview"("employeeId", "interviewDate");

-- CreateIndex
CREATE INDEX "Interview_interviewStepId_idx" ON "Interview"("interviewStepId");

-- CreateIndex
CREATE INDEX "Education_candidateId_idx" ON "Education"("candidateId");

-- CreateIndex
CREATE INDEX "WorkExperience_candidateId_idx" ON "WorkExperience"("candidateId");

-- CreateIndex
CREATE INDEX "Resume_candidateId_idx" ON "Resume"("candidateId");

-- AddForeignKey
ALTER TABLE "Employee" ADD CONSTRAINT "Employee_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES "Company"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Position" ADD CONSTRAINT "Position_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES "Company"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Position" ADD CONSTRAINT "Position_interviewFlowId_fkey" FOREIGN KEY ("interviewFlowId") REFERENCES "InterviewFlow"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InterviewStep" ADD CONSTRAINT "InterviewStep_interviewFlowId_fkey" FOREIGN KEY ("interviewFlowId") REFERENCES "InterviewFlow"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InterviewStep" ADD CONSTRAINT "InterviewStep_interviewTypeId_fkey" FOREIGN KEY ("interviewTypeId") REFERENCES "InterviewType"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Application" ADD CONSTRAINT "Application_positionId_fkey" FOREIGN KEY ("positionId") REFERENCES "Position"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Application" ADD CONSTRAINT "Application_candidateId_fkey" FOREIGN KEY ("candidateId") REFERENCES "Candidate"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Interview" ADD CONSTRAINT "Interview_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES "Application"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Interview" ADD CONSTRAINT "Interview_interviewStepId_fkey" FOREIGN KEY ("interviewStepId") REFERENCES "InterviewStep"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Interview" ADD CONSTRAINT "Interview_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "Employee"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
